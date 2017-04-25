/**
* Utility methods for interacting with escalations
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
* @testClasses EscalationUtils_Test
*/
global with sharing class EscalationUtils {
	/**
	* Logic for stoping a trigger recursion
	*/
	private static boolean firstRun = true;

	/**
	* Determine if firstRun is true or not
	* @return the firstRun
	*/
	global static boolean isFirstRun() {
		return firstRun;
	}

	/**
	* Sets firstRun
	*/
	global static void setFirstRunFalse(){
		firstRun = false;
	}

	/**
	* Gets a list of escalations for a give id set
	*
	* @param ids The escalation ids to query
	* @return The escalations
	*/
	global static List<rh_escal__Escalation__c> getEscalations(Set<Id> ids) {
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
	global static Map<Id, rh_escal__Escalation__c> getEscalationMap(Set<Id> ids) {
		return new Map<Id, rh_escal__Escalation__c>(getEscalations(ids));
	}

	/**
	* Gets an escalation
	*
	* @param id The id to query
	* @return The escalation
	*/
	global static rh_escal__Escalation__c getEscalation(Id id) {
		return getEscalationMap(new Set<Id> {id}).get(id);
	}

	/**
	* Gets a map of cases
	*
	* @param Set<Id> The caseIds to query
	* @return The map of cases
	*/
	public static Map<Id, Case> getCaseMapByIds(Set<Id> caseIds) {
		return new Map<Id, Case>([
			select Account.AccountNumber,
				Account.Name,
				AccountId,
				BusinessHoursId,
				CaseNumber,
				OwnerId,
				Contact.Email,
				ContactId,
				Contact.Name,
				CreatedById,
				ClosedDate,
				CreatedDate,
				LastModifiedById,
				rh_escal__EngineeringReqNumber__c,
				rh_escal__PotentialLiability__c,
				rh_escal__Product__c,
				rh_escal__SLAViolation__c,
				Status,
				Subject,
				Type
			from Case
			where Id in :caseIds
		]);
	}
}