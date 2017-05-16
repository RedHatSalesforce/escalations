/**
* Trigger work for escalation
*
* @author Preeti (ppreeti@redhat.com)
* @testClasses EscalationTrigger_Test
*/
public with sharing class EscalationTrigger extends BaseTrigger {
	/** The old map of objects */
	@TestVisible Map<Id, rh_escal__Escalation__c> oldMap {
		get {
			return (Map<Id, rh_escal__Escalation__c>) ((BaseTrigger) this).baseOldMap;
		}
		set;
	}

	/** The new map of objects */
	@TestVisible Map<Id, rh_escal__Escalation__c> newMap {
		get {
			if (this.newMap == null) {
				this.newMap = new Map<Id, rh_escal__Escalation__c>();

				if (!this.isBefore && !this.newObjs.isEmpty()) {
					this.newMap = new Map<Id, rh_escal__Escalation__c>(this.newObjs);
				}
			}

			return this.newMap;
		}
		set;
	}

	/** The new list of objects */
	@TestVisible List<rh_escal__Escalation__c> newObjs {
		get {
			return (List<rh_escal__Escalation__c>) ((BaseTrigger) this).baseNewObjs;
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
	public EscalationTrigger(Map<Id, rh_escal__Escalation__c> xoldMap, List<rh_escal__Escalation__c> xnewObjs, Boolean isBefore) {
		super(xoldMap, xnewObjs, isBefore);
	}

	/**
	* Sets the name of the trigger
	*
	* @return The name of the trigger
	*/
	public override String getTriggerName() {
		return 'EscalationTrigger';
	}

	public static final String PRIMARYCASE_UPDATION_NOT_ALLOWED = 'Update the primary case by updating or adding an escalation case record';
	public static final String DEFAULT_ESCAL_ROUTER = 'DEFAULT';

	public static Boolean IS_ADDING_ESCALATIONCASE = false;

	/**
	* Sets IS_ADDING_ESCALATIONCASE
	*/
	public static void setIsAddingEscalationCase(){
		IS_ADDING_ESCALATIONCASE = true;
	}

	/**
	* Auto populate the account on the escalation if account is not set and primary case of the account is set.
	*
	* NOTE: On update it will only work if their is a change in primary case value and account is null.
	*/
	@TestVisible
	private void setAccountWhenPrimaryCaseIsNotNull() {
		if (this.isDelete) {
			return;
		}

		Set<Id> caseIdSet = new Set<Id>();

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			caseIdSet.add(escalation.rh_escal__PrimaryCase__c);
		}

		caseIdSet.remove(null);

		if(caseIdSet.isEmpty()) {
			return;
		}

		Map<Id, Case> caseMap = EscalationUtils.getCaseMapByIds(caseIdSet);

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			Boolean nullAccount = (escalation.rh_escal__Account__c == null);
			Boolean nullPrimaryCase = (escalation.rh_escal__PrimaryCase__c == null);
			Id primaryCaseId = escalation.rh_escal__primaryCase__c;

			if (
				nullAccount && !nullPrimaryCase &&
				(
					this.isInsert ||
					(
						this.oldMap.get(escalation.Id).rh_escal__PrimaryCase__c != escalation.rh_escal__PrimaryCase__c
					)
				)
			) {
				escalation.rh_escal__Account__c = caseMap.get(primaryCaseId).AccountId;
			}
		}
	}

	/**
	* Auto populate the rh_escal__EscalationCase__c	record if primary case of the escalation is not null.
	*/
	@TestVisible
	private void createEscalationCaseWhenPrimaryCaseIsNotNull() {
		if (!this.isInsert) {
			return;
		}

		List<rh_escal__EscalationCase__c> escalCasesToInsert = new List<rh_escal__EscalationCase__c>();

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			if (escalation.rh_escal__PrimaryCase__c == null) {
				continue;
			}

			escalCasesToInsert.add(new rh_escal__EscalationCase__c(
				rh_escal__Case__c = escalation.rh_escal__PrimaryCase__c,
				rh_escal__Primary__c = true,
				rh_escal__Escalation__c = escalation.Id
			));
		}

		if (!escalCasesToInsert.isEmpty()) {
			insert escalCasesToInsert;
		}
	}

	/**
	* Do not allow setting of primary case on escalation update events.
	*/
	@TestVisible
	private void doNotAllowUpdateOfPrimaryCase() {
		if (!this.isUpdate || IS_ADDING_ESCALATIONCASE) {
			return;
		}

		Set<Id> escalationIds = new Set<Id>();

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			if (escalation.rh_escal__PrimaryCase__c != null) {
				escalationIds.add(escalation.Id);
			}
		}

		escalationIds.remove(null);
		Set<Id> caseIds = new set<Id>();

		Map<Id, List<rh_escal__EscalationCase__c>> existingEscalationCases = EscalationCaseUtils.getEscalationCasesForEscalations(escalationIds);

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			if (
				existingEscalationCases.containsKey(escalation.Id)
			) {
				for (rh_escal__EscalationCase__c escalCase : existingEscalationCases.get(escalation.Id)) {
					if (escalCase.rh_escal__Primary__c) {
						caseIds.add(escalCase.rh_escal__Case__c);
					}
				}
			}
		}

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			Boolean primaryCaseUpdated = this.oldMap.get(escalation.Id).rh_escal__PrimaryCase__c != escalation.rh_escal__PrimaryCase__c;

			if (
				!primaryCaseUpdated
			) {
				continue;
			} else if (
				primaryCaseUpdated &&
				caseIds.contains(escalation.rh_escal__PrimaryCase__c)
			) {
				continue;
			} else {
				escalation.rh_escal__PrimaryCase__c.addError(PRIMARYCASE_UPDATION_NOT_ALLOWED);
			}
		}
	}

	/**
	* Assign default owner to an escalation
	*/
	@TestVisible
	private void assignDefaultOwner() {
		if (!this.isInsert) {
			return;
		}

		rh_escal__EscalationRouter__c er = rh_escal__EscalationRouter__c.getValues(DEFAULT_ESCAL_ROUTER);

		for (rh_escal__Escalation__c escalation : this.newObjs) {
			if (er != null && er.rh_escal__DefaultOwner__c != null) {
				escalation.OwnerId = er.rh_escal__DefaultOwner__c;
			}
		}
	}

	/**
	* Perform actions that should be done in the 'before' part of a trigger
	*/
	@TestVisible
	protected override void runBefore() {
		super.runBefore();

		if (this.numberOfBeforeRuns == 1) {
			this.setAccountWhenPrimaryCaseIsNotNull();
			this.doNotAllowUpdateOfPrimaryCase();
			this.assignDefaultOwner();
		}
	}

	/**
	* Perform actions that should be done in the 'after' part of a trigger
	*/
	@TestVisible
	protected override void runAfter() {
		super.runAfter();

		if (this.numberOfAfterRuns == 1) {
			this.createEscalationCaseWhenPrimaryCaseIsNotNull();
		}
	}
}