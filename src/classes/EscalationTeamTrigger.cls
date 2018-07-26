/**
* Trigger work for escalation teams
*
* @author Preeti (ppreeti@redhat.com)
* @testClasses EscalationTeamTrigger_Test
*/
public with sharing class EscalationTeamTrigger extends BaseTrigger {
	/** The old map of objects */
	@TestVisible Map<Id, rh_escal__EscalationTeam__c> oldMap {
		get {
			return (Map<Id, rh_escal__EscalationTeam__c>) ((BaseTrigger) this).baseOldMap;
		}
		set;
	}

	/** The new map of objects */
	@TestVisible Map<Id, rh_escal__EscalationTeam__c> newMap {
		get {
			if (this.newMap == null) {
				this.newMap = new Map<Id, rh_escal__EscalationTeam__c>();

				if (!this.isBefore && !this.newObjs.isEmpty()) {
					this.newMap = new Map<Id, rh_escal__EscalationTeam__c>(this.newObjs);
				}
			}

			return this.newMap;
		}
		set;
	}

	/** The new list of objects */
	@TestVisible List<rh_escal__EscalationTeam__c> newObjs {
		get {
			return (List<rh_escal__EscalationTeam__c>) ((BaseTrigger) this).baseNewObjs;
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
	public EscalationTeamTrigger(Map<Id, rh_escal__EscalationTeam__c> xoldMap, List<rh_escal__EscalationTeam__c> xnewObjs, Boolean isBefore) {
		super(xoldMap, xnewObjs, isBefore);
	}

	/**
	* Sets the name of the trigger
	*
	* @return The name of the trigger
	*/
	public override String getTriggerName() {
		return 'EscalationTeamTrigger';
	}

	/**
	* Ensure that the team member has exactly one contact method, no more or less, or raise an exception
	*/
	@TestVisible
	private void ensureValidTeamMember() {
		if (this.isDelete) {
			return;
		}
		for (rh_escal__EscalationTeam__c team : this.newObjs) {
			EscalationTeamUtils.ensureOnlyOneContactTypeSet(team);
		}
	}

	/**
	* Do not allow addition of duplicate team members on an escalation
	*/
	@TestVisible
	private void teamDupCheck() {
		if (this.isDelete) {
			return;
		}

		Set<Id> escalationIds = new Set<Id>();

		for (rh_escal__EscalationTeam__c team: this.newObjs) {
			escalationIds.add(team.rh_escal__Escalation__c);
		}

		escalationIds.remove(null);

		if (escalationIds.isEmpty()) {
			return;
		}

		Map<Id, Set<Id>> escalToMembers = new Map<Id, Set<Id>>();
		Map<Id, Set<String>> escalToEmails = new Map<Id, Set<String>>();

		for (Id escalationId : escalationIds) {
			escalToMembers.put(escalationId, new Set<Id>());
			escalToEmails.put(escalationId, new Set<String>());
		}


		for (rh_escal__EscalationTeam__c team: EscalationTeamUtils.getEscalationTeamMembers(escalationIds)) {
			escalToMembers.get(team.rh_escal__Escalation__c).add(team.rh_escal__Contact__c);
			escalToMembers.get(team.rh_escal__Escalation__c).add(team.rh_escal__User__c);
			escalToEmails.get(team.rh_escal__Escalation__c).add(team.rh_escal__Email__c);
		}

		escalToMembers.remove(null);
		escalToEmails.remove(null);

		for (rh_escal__EscalationTeam__c team: this.newObjs) {
			Set<Id> members = escalToMembers.get(team.rh_escal__Escalation__c);
			Set<String> emails = escalToEmails.get(team.rh_escal__Escalation__c);
			Boolean alreadyExists = EscalationTeamUtils.checkMemberAlreadyExists(team, members, emails);

			if (alreadyExists && (isInsert || EscalationTeamUtils.memberValuesChanged(this.oldMap, team))) {
				team.addError(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED);
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
			this.ensureValidTeamMember();
			this.teamDupCheck();
		}
	}
}
