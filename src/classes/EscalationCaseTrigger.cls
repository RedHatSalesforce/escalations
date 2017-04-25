/**
* Trigger work for escalation cases
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
* @testClasses EscalationCaseTrigger_Test
*/
public with sharing class EscalationCaseTrigger extends BaseTrigger {
	/** Error message text for when the last case on an escalation has it's primary flag unchecked */
	@TestVisible private static String MSG_LAST_CASE_MUST_BE_PRIMARY = 'The only case associated with an escalation must be the primary case';

	/** Erorr message text for when a bulk update is attempted */
	@TestVisible private static String MSG_NO_BULK_UPDATE = 'Currently bulk updates of escalation cases are not supported';

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
			if (this.newMap == null) {
				this.newMap = new Map<Id, rh_escal__EscalationCase__c>();

				if (!this.isBefore && !this.newObjs.isEmpty()) {
					this.newMap = new Map<Id, rh_escal__EscalationCase__c>(this.newObjs);
				}
			}

			return this.newMap;
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
		Map<Id, rh_escal__Escalation__c> escalationMap = EscalationUtils.getEscalationMap(escalationToEscalationCaseMap.keySet());

		Map<Id, rh_escal__Escalation__c> escalationsToUpdate = new Map<Id, rh_escal__Escalation__c>();
		List<rh_escal__EscalationCase__c> escalationCasesToUpdate = new List<rh_escal__EscalationCase__c>();
		Set<String> newPrimaryIdentifierSet = new Set<String>();

		for (rh_escal__EscalationCase__c escalationCase : this.newObjs) {
			if (!existingEscalationCases.isEmpty()) {
				for (rh_escal__EscalationCase__c existingEscalationCase : existingEscalationCases.get(escalationCase.rh_escal__Escalation__c)) {
					if (escalationCase.rh_escal__Case__c == existingEscalationCase.rh_escal__Case__c) {
						escalationCase.addError(EscalationCaseUtils.CASE_ALREADY_LINKED);
					}
				}
			}

			rh_escal__Escalation__c escalation = escalationMap.get(escalationCase.rh_escal__Escalation__c);
			Boolean wantsToBePrimary = (escalationCase.rh_escal__Primary__c == true);
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

			if (existingEscalationCases.containsKey(escalation.Id)) {
				for (rh_escal__EscalationCase__c existingEscalationCase : existingEscalationCases.get(escalation.Id)) {
					escalationCasesToUpdate.add(new rh_escal__EscalationCase__c(
						Id = existingEscalationCase.Id,
						rh_escal__Primary__c = false
					));
				}
			}
		}

		for (rh_escal__EscalationCase__c escalationCase : this.newObjs) {
			rh_escal__Escalation__c escalation = escalationMap.get(escalationCase.rh_escal__Escalation__c);
			String identifier = '' + escalationCase.rh_escal__Escalation__c + escalationCase.rh_escal__Case__c;

			Boolean alreadySetPrimary = escalationsToUpdate.containsKey(escalationCase.rh_escal__Escalation__c);
			Boolean alreadyHasPrimary = (escalation.rh_escal__PrimaryCase__c != null);
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
			EscalationUtils.setFirstRunFalse();
			update escalationsToUpdate.values();
		}
	}

	/**
	* Reset the primary case to the oldest (non-same) case on an escalation when the
	* primary flag is removed from the escalation
	*/
	@TestVisible
	private void setPrimaryCaseOnUpdate() {
		if (!this.isUpdate) {
			return;
		}

		// This is bad and should be addressed.  But given time constraint #6 was filed
		if (this.isBulk) {
			throw new BaseTrigger.NoBulkException(MSG_NO_BULK_UPDATE);
		}

		// This .get is bit rediculous but until #6 is addressed it's the best way to get
		// test coverage for the this.newMap code
		rh_escal__EscalationCase__c escalationCase = this.newMap.get(this.newObjs.get(0).Id);
		rh_escal__EscalationCase__c oldEscalationCase = this.oldMap.get(escalationCase.Id);
		rh_escal__Escalation__c escalation = EscalationUtils.getEscalation(escalationCase.rh_escal__Escalation__c);

		Map<Id, List<rh_escal__EscalationCase__c>> existingEscalationCases = EscalationCaseUtils.getEscalationCasesForEscalations(new Set<Id> {escalationCase.rh_escal__Escalation__c});

		List<rh_escal__Escalation__c> escalationsToUpdate = new List<rh_escal__Escalation__c>();
		List<rh_escal__EscalationCase__c> escalationCasesToUpdate = new List<rh_escal__EscalationCase__c>();

		// We've got a new primary.  Need to set the old primary to false and update the
		// parent escalation
		if (escalationCase.rh_escal__Primary__c) {
			escalationsToUpdate.add(new rh_escal__Escalation__c(
				Id = escalationCase.rh_escal__Escalation__c,
				rh_escal__PrimaryCase__c = escalationCase.rh_escal__Case__c
			));

			for (rh_escal__EscalationCase__c otherEscalationCase : existingEscalationCases.get(escalationCase.rh_escal__Escalation__c)) {
				if (escalationCase.Id == otherEscalationCase.Id) {
					continue;
				}

				if (otherEscalationCase.rh_escal__Primary__c) {
					escalationCasesToUpdate.add(new rh_escal__EscalationCase__c(
						Id = otherEscalationCase.Id,
						rh_escal__Primary__c = false
					));
				}
			}
		} else if (escalation.rh_escal__PrimaryCase__c == escalationCase.rh_escal__Case__c) {
			// We're removing the old primary
			Id newPrimary = null;
			Id newPrimaryCase = null;

			for (rh_escal__EscalationCase__c otherEscalationCase : existingEscalationCases.get(escalationCase.rh_escal__Escalation__c)) {
				if (escalationCase.Id == otherEscalationCase.Id) {
					continue;
				}

				newPrimary = otherEscalationCase.Id;
				newPrimaryCase = otherEscalationCase.rh_escal__Case__c;
				break;
			}

			if (newPrimary == null) {
				this.newObjs.get(0).rh_escal__Primary__c.addError(MSG_LAST_CASE_MUST_BE_PRIMARY);
				return;
			}

			escalationsToUpdate.add(new rh_escal__Escalation__c(
				Id = escalationCase.rh_escal__Escalation__c,
				rh_escal__PrimaryCase__c = newPrimaryCase
			));

			escalationCasesToUpdate.add(new rh_escal__EscalationCase__c(
				Id = newPrimary,
				rh_escal__Primary__c = true
			));
		}

		if (!escalationsToUpdate.isEmpty()) {
			update escalationsToUpdate;
		}

		if (!escalationCasesToUpdate.isEmpty()) {
			update escalationCasesToUpdate;
		}
	}

	/**
	* Sets the primary case (or clears it) when the primary is deleted
	*/
	@TestVisible
	private void setPrimaryCaseOnDelete() {
		if (!this.isDelete) {
			return;
		}

		Set<Id> escalationCaseIds = new Set<Id>();
		Set<Id> escalationIds = new Set<Id>();

		// This only trigger only matters if we are deleting the primary case
		//  so we'll gather up all of the ids of the ones that are being deleted
		for (rh_escal__EscalationCase__c escalationCase : this.oldMap.values()) {
			if (escalationCase.rh_escal__Primary__c) {
				escalationCaseIds.add(escalationCase.Id);
				escalationIds.add(escalationCase.rh_escal__Escalation__c);
			}
		}

		// If we aren't deleting any primary case linkage, just bail out
		if (escalationCaseIds.isEmpty()) {
			return;
		}

		Map<Id, rh_escal__Escalation__c> escalationMap = EscalationUtils.getEscalationMap(escalationIds);
		Map<Id, List<rh_escal__EscalationCase__c>> existingEscalationCases = EscalationCaseUtils.getEscalationCasesForEscalations(escalationIds);

		List<rh_escal__Escalation__c> escalationsToUpdate = new List<rh_escal__Escalation__c>();
		List<rh_escal__EscalationCase__c> escalationCasesToUpdate = new List<rh_escal__EscalationCase__c>();

		for (Id id : escalationCaseIds) {
			rh_escal__EscalationCase__c escalationCase = this.oldMap.get(id);

			// If we have more escalations cases we want to pick one of the existing ones to be the primary
			if (
				existingEscalationCases.containsKey(escalationCase.rh_escal__Escalation__c) &&
				!existingEscalationCases.get(escalationCase.rh_escal__Escalation__c).isEmpty()
			) {
				// Since the EscalationUtils call returns these ordered by CreatedDate we can just pluck
				//  the first one and use it as our new primary
				rh_escal__EscalationCase__c newPrimaryEscalationCase = existingEscalationCases.get(escalationCase.rh_escal__Escalation__c).get(0);

				escalationsToUpdate.add(new rh_escal__Escalation__c(
					Id = escalationCase.rh_escal__Escalation__c,
					rh_escal__PrimaryCase__c = newPrimaryEscalationCase.rh_escal__Case__c
				));

				escalationCasesToUpdate.add(new rh_escal__EscalationCase__c(
					Id = newPrimaryEscalationCase.Id,
					rh_escal__Primary__c = true
				));
			} else {
				// If we don't have any escalation cases, we just want to clear the primary case field
				escalationsToUpdate.add(new rh_escal__Escalation__c(
					Id = escalationCase.rh_escal__Escalation__c,
					rh_escal__PrimaryCase__c = null
				));
			}
		}

		if (!escalationsToUpdate.isEmpty()) {
			update escalationsToUpdate;
		}

		if (!escalationCasesToUpdate.isEmpty()) {
			update escalationCasesToUpdate;
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

	/**
	* Perform actions that should be done in the 'after' part of a trigger
	*/
	@TestVisible
	protected override void runAfter() {
		super.runAfter();

		if (this.numberOfBeforeRuns == 1 && this.numberOfAfterRuns == 1) {
			this.setPrimaryCaseOnUpdate();
		}

		if (this.numberOfAfterRuns == 1) {
			this.setPrimaryCaseOnDelete();
		}
	}
}