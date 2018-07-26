/**
* Utility methods for escalation teams
*
* @author Preeti (ppreeti@redhat.com)
* @testClasses EscalationTeamUtils_Test
*/
global with sharing class EscalationTeamUtils {
	public static final String TEAM_MEMBER_ALREADY_LINKED = 'Team member is already linked to the escalation, please try linking another member';

	public static final String MSG_INVALID_TEAM_TOO_MANY_TYPES = 'Team members can only have one contact type, Contact, Email or User';
	public static final String MSG_INVALID_TEAM_NO_TYPES = 'Team members must have a Contact, Email or User';

	public virtual class InvalidException extends Exception {}


	/**
	* Gets a list of escalation team members for a given id set
	*
	* @param escalIds The escalation ids to query
	* @return The escalation team members
	*/
	global static List<rh_escal__EscalationTeam__c> getEscalationTeamMembers(Set<Id> escalIds) {
		return [
			select rh_escal__Contact__c,
				rh_escal__Email__c,
				rh_escal__Escalation__c,
				rh_escal__Internal__c,
				rh_escal__Type__c,
				rh_escal__User__c
			from rh_escal__EscalationTeam__c
			where rh_escal__Escalation__c in :escalIds
		];
	}

	/**
	* Gets a map of escalation team members ids to escalation team members
	*
	* @param ids The escalation ids to query
	* @return The map of ids to escalation team members
	*/
	global static Map<Id, rh_escal__EscalationTeam__c> getEscalationTeamMemberMap(Set<Id> ids) {
		return new Map<Id, rh_escal__EscalationTeam__c>(getEscalationTeamMembers(ids));
	}

	/**
	* Check if the member's ID or email already exists for another team member
	*
	* @param member The team member
	* @param existingMembers A set of team memberIds for the existing team.
	* @param emails A set of email addresses for the existing team
	*
	* @return
	*/
	public static Boolean checkMemberAlreadyExists(rh_escal__EscalationTeam__c member, Set<Id> existingMembers, Set<String> emails) {
		Boolean contactIsNotNull = member.rh_escal__Contact__c != null;
		Boolean userIsNotNull = member.rh_escal__User__c != null;
		Boolean emailIsNotNull = member.rh_escal__Email__c != null;

		Boolean contactSetAndInTeam = contactIsNotNull && existingMembers.contains(member.rh_escal__Contact__c);
		Boolean userSetAndInTeam = userIsNotNull && existingMembers.contains(member.rh_escal__User__c);
		Boolean emailSetAndInTeam = emailIsNotNull && emails.contains(member.rh_escal__Email__c);
		return contactSetAndInTeam || userSetAndInTeam || emailSetAndInTeam;
	}


	/**
	* determine if an escalation team member has changed any of it's values
	*
	* @param oldTeamMemberMap Map of Ids to The previous version of the team member records
	* @param newTeamMember The new version of the team member record
	*
	* @return if the record has been amended
	*/
	public static Boolean memberValuesChanged(Map<Id, rh_escal__EscalationTeam__c> oldTeamMemberMap, rh_escal__EscalationTeam__c newTeamMember) {
		rh_escal__EscalationTeam__c oldTeamMember = oldTeamMemberMap.get(newTeamMember.Id);

		Boolean contactChanged = oldTeamMember.rh_escal__Contact__c != newTeamMember.rh_escal__Contact__c;
		Boolean userChanged = oldTeamMember.rh_escal__User__c != newTeamMember.rh_escal__User__c;
		Boolean emailChanged = oldTeamMember.rh_escal__Email__c != newTeamMember.rh_escal__Email__c;

		return contactChanged || userChanged || emailChanged;
	}

	/**
	* Ensure that the team member has exactly one contact method.
	*
	* @param teamMember The team member
	* @throws InvalidException if
	*/
	public static void ensureOnlyOneContactTypeSet(rh_escal__EscalationTeam__c teamMember) {
		Integer credentialsCount = 0;
		credentialsCount += teamMember.rh_escal__Contact__c != null ? 1 : 0;
		credentialsCount += teamMember.rh_escal__User__c != null ? 1 : 0;
		credentialsCount += teamMember.rh_escal__Email__c != null ? 1 : 0;

		if (credentialsCount > 1) {
			throw new InvalidException(MSG_INVALID_TEAM_TOO_MANY_TYPES);
		} else if (credentialsCount == 0) {
			throw new InvalidException(MSG_INVALID_TEAM_NO_TYPES);
		}
	}
}