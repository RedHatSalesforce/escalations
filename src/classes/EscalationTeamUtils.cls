/**
* Utility methods for escalation teams
*
* @author Preeti (ppreeti@redhat.com)
* @testClasses EscalationTeamUtils_Test
*/
global with sharing class EscalationTeamUtils {
	public static final String TEAM_MEMBER_ALREADY_LINKED = 'Team member is already linked to the escalation, please try linking another member';

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
}