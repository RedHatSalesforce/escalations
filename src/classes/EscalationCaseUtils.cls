/**
* Utility methods for escalation cases
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
* @testClasses EscalationCaseUtils_Test
*/
public with sharing class EscalationCaseUtils {
	public static final String CASE_ALREADY_LINKED = 'Case is already linked to the escalation, please try linking another case';

	/**
	* Gets the escalation ids for a given list of escalation cases
	*
	* @param escalationCases The escalation cases to dig through
	* @return The escalation ids
	*/
	public static Set<Id> getEscalationIds(List<rh_escal__EscalationCase__c> escalationCases) {
		Set<Id> escalationIds = new Set<Id>();

		for (rh_escal__EscalationCase__c escalationCase : escalationCases) {
			escalationIds.add(escalationCase.rh_escal__Escalation__c);
		}

		return escalationIds;
	}

	/**
	* Gets a map of escalation ids to the related escalation cases
	*
	* @param escalationCases The escalation cases to dig through
	* @return A map of escalation ids to a list of escalation cases
	*/
	public static Map<Id, List<rh_escal__EscalationCase__c>> buildEscalationToCaseMap(List<rh_escal__EscalationCase__c> escalationCases) {
		Map<Id, List<rh_escal__EscalationCase__c>> escalationToEscalationCaseMap = new Map<Id, List<rh_escal__EscalationCase__c>>();

		for (rh_escal__EscalationCase__c escalationCase : escalationCases) {
			if (!escalationToEscalationCaseMap.containsKey(escalationCase.rh_escal__Escalation__c)) {
				escalationToEscalationCaseMap.put(escalationCase.rh_escal__Escalation__c, new List<rh_escal__EscalationCase__c>());
			}

			escalationToEscalationCaseMap.get(escalationCase.rh_escal__Escalation__c).add(escalationCase);
		}

		return escalationToEscalationCaseMap;
	}

	/**
	* Gets a map of escalation ids to the related escalation cases
	*
	* @param escalationIds The escalations to get the cases from
	* @return A map of escalation ids to a list of escalation cases
	*/
	public static Map<Id, List<rh_escal__EscalationCase__c>> getEscalationCasesForEscalations(Set<Id> escalationIds) {
		List<rh_escal__EscalationCase__c> escalationCases = [
			select rh_escal__Case__c,
				rh_escal__Escalation__c,
				rh_escal__Primary__c
			from rh_escal__EscalationCase__c
			where rh_escal__Escalation__c in :escalationIds
			order by CreatedDate asc
		];

		return buildEscalationToCaseMap(escalationCases);
	}
}