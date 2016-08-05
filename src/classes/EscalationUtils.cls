/**
* Utility methods for interacting with escalations
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
* @testClasses EscalationUtils_Test
*/
public with sharing class EscalationUtils {
	/**
	* Gets a list of escalations for a give id set
	*
	* @param ids The escalation ids to query
	* @return The escalations
	*/
	public static List<rh_escal__Escalation__c> getEscalations(Set<Id> ids) {
		return [
			select rh_escal__CaseCount__c,
				rh_escal__PrimaryCase__c,
				rh_escal__Subject__c
			from rh_escal__Escalation__c
			where Id in :ids
		];
	}

	/**
	* Gets a map of escalation ids to escalations
	*
	* @param ids The escalation ids to query
	* @return The map of ids to escalations
	*/
	public static Map<Id, rh_escal__Escalation__c> getEscalationMap(Set<Id> ids) {
		return new Map<Id, rh_escal__Escalation__c>(getEscalations(ids));
	}
}