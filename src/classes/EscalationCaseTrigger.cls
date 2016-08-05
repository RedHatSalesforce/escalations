/**
* Trigger work for escalation cases
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
* @testClasses EscalationCaseTrigger_Trigger
*/
public with sharing class EscalationCaseTrigger extends BaseTrigger {
	/** The old map of objects */
	@TestVisible Map<Id, rh_escal__EscalationCase__c> oldMap {
		get {
			return (Map<Id, rh_escal__EscalationCase__c>) ((BaseTrigger) this).baseOldMap;
		}
		set;
	}

	/** The new map of objects */
	@TestVisible Map<Id, rh_escal__EscalationCase__c> newMap {
		get {
			return (Map<Id, rh_escal__EscalationCase__c>) ((BaseTrigger) this).baseNewMap;
		}
		set;
	}

	/** The new list of objects */
	@TestVisible List<rh_escal__EscalationCase__c> newObjs {
		get {
			return (List<rh_escal__EscalationCase__c>) ((BaseTrigger) this).baseNewObjs;
		}
		set;
	}

	/**
	* The constructor
	*
	* @param xoldMap The old map from the trigger
	* @param xnewObj The list of new objects from the trigger
	* @param isBefore If the trigger is in before or after
	*/
	public EscalationCaseTrigger(Map<Id, rh_escal__EscalationCase__c> xoldMap, List<rh_escal__EscalationCase__c> xnewObjs, Boolean isBefore) {
		super(xoldMap, xnewObjs, isBefore);
	}

	/**
	* Sets the name of the trigger
	*
	* @return The name of the trigger
	*/
	public override String getTriggerName() {
		return 'EscalationCaseTrigger';
	}

	/**
	* Set the primary case on the escalation if it is the only one on the escalation.
	*
	* NOTE: If multiple escalation cases are inserted for a single escalation in a single
	*       pass, then only the "first" one will be chosen.
	*/
	@TestVisible
	private void setPrimaryCaseOnInsert() {
		if (!this.isInsert) {
			return;
		}

		Map<Id, List<rh_escal__EscalationCase__c>> escalationToEscalationCaseMap = EscalationCaseUtils.buildEscalationToCaseMap(this.newObjs);
		Map<Id, List<rh_escal__EscalationCase__c>> existingEscalationCases = EscalationCaseUtils.getEscalationCasesForEscalations(escalationToEscalationCaseMap.keySet());
		Map<Id, rh_escal__Escalation__c> escalationMap = new Map<Id, rh_escal__Escalation__c>(EscalationUtils.getEscalations(escalationToEscalationCaseMap.keySet()));

		Map<Id, rh_escal__Escalation__c> escalationsToUpdate = new Map<Id, rh_escal__Escalation__c>();
		List<rh_escal__EscalationCase__c> escalationCasesToUpdate = new List<rh_escal__EscalationCase__c>();
		Set<String> newPrimaryIdentifierSet = new Set<String>();

		for (rh_escal__EscalationCase__c escalationCase : this.newObjs) {
			rh_escal__Escalation__c escalation = escalationMap.get(escalationCase.rh_escal__Escalation__c);
			Boolean wantsToBePrimary = escalationCase.rh_escal__Primary__c == true;
			Boolean alreadyHasPrimary = escalationsToUpdate.containsKey(escalationCase.rh_escal__Escalation__c);

			if (
				!wantsToBePrimary ||
				alreadyHasPrimary
			) {
				continue;
			}

			String identifier = '' + escalationCase.rh_escal__Escalation__c + escalationCase.rh_escal__Case__c;
			newPrimaryIdentifierSet.add(identifier);
			escalationsToUpdate.put(
				escalation.Id,
				new rh_escal__Escalation__c(
					Id = escalation.Id,
					rh_escal__PrimaryCase__c = escalationCase.rh_escal__Case__c
				)
			);

			for (rh_escal__EscalationCase__c existingEscalationCase : existingEscalationCases.get(escalation.Id)) {
				escalationCasesToUpdate.add(new rh_escal__EscalationCase__c(
					Id = existingEscalationCase.Id,
					rh_escal__Primary__c = false
				));
			}
		}

		for (rh_escal__EscalationCase__c escalationCase : this.newObjs) {
			rh_escal__Escalation__c escalation = escalationMap.get(escalationCase.rh_escal__Escalation__c);
			String identifier = '' + escalationCase.rh_escal__Escalation__c + escalationCase.rh_escal__Case__c;

			Boolean alreadySetPrimary = escalationsToUpdate.containsKey(escalationCase.rh_escal__Escalation__c);
			Boolean alreadyHasPrimary = escalation.rh_escal__PrimaryCase__c != null;
			Boolean isNewPrimary = newPrimaryIdentifierSet.contains(identifier);

			if (alreadySetPrimary || alreadyHasPrimary) {
				if (!isNewPrimary) {
					escalationCase.rh_escal__Primary__c = false;
				}

				continue;
			}

			escalationsToUpdate.put(
				escalation.Id,
				new rh_escal__Escalation__c(
					Id = escalation.Id,
					rh_escal__PrimaryCase__c = escalationCase.rh_escal__Case__c
				)
			);

			escalationCase.rh_escal__Primary__c = true;
		}

		if (!escalationCasesToUpdate.isEmpty()) {
			update escalationCasesToUpdate;
		}

		if (!escalationsToUpdate.isEmpty()) {
			update escalationsToUpdate.values();
		}
	}

	/**
	* Perform actions that should be done in the 'before' part of a trigger
	*/
	@TestVisible
	protected override void runBefore() {
		super.runBefore();

		if (this.numberOfBeforeRuns == 1) {
			this.setPrimaryCaseOnInsert();
		}
	}
}