/**
* Test for the escalation utility methods
*
* @author Patrick Connelly (patrick@deadlypenguin.com
*/

@isTest
private class EscalationUtils_Test {
	static testMethod void getEscalations() {
		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2
		};

		Map<Id, rh_escal__Escalation__c> expectedResults = new Map<Id, rh_escal__Escalation__c> {
			testEscalation1.Id => testEscalation1,
			testEscalation2.Id => testEscalation2
		};

		Test.startTest();

		List<rh_escal__Escalation__c> results = EscalationUtils.getEscalations(expectedResults.keySet());

		Test.stopTest();

		System.assertEquals(2, results.size(), 'Did not get the expected number of escalations back');

		for (rh_escal__Escalation__c result : results) {
			System.assert(expectedResults.containsKey(result.Id), 'Got an escalation back that we did not expect');
			System.assertEquals(expectedResults.get(result.Id).rh_escal__Subject__c, result.rh_escal__Subject__c, 'Got the wrong escalation back');
			expectedResults.remove(result.Id);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the expected results');
	}

	static testMethod void getEscalationMap() {
		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2
		};

		Map<Id, rh_escal__Escalation__c> expectedResults = new Map<Id, rh_escal__Escalation__c> {
			testEscalation1.Id => testEscalation1,
			testEscalation2.Id => testEscalation2
		};

		Test.startTest();

		Map<Id, rh_escal__Escalation__c> results = EscalationUtils.getEscalationMap(expectedResults.keySet());

		Test.stopTest();

		System.assertEquals(2, results.size(), 'Did not get the expected number of escalations back');

		for (Id id : results.keySet()) {
			rh_escal__Escalation__c result = results.get(id);
			System.assert(expectedResults.containsKey(result.Id), 'Got an escalation back that we did not expect');
			System.assertEquals(expectedResults.get(result.Id).rh_escal__Subject__c, result.rh_escal__Subject__c, 'Got the wrong escalation back');
			expectedResults.remove(result.Id);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the expected results');
	}
}