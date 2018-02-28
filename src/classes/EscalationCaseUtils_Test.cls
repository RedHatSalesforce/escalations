/**
* Test for the escalation case utilitites
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
*/

@IsTest
private class EscalationCaseUtils_Test {
	static testMethod void getEscalationIds() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation3 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2,
			testEscalation3
		};

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation1, testCase);
		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation2, testCase);
		rh_escal__EscalationCase__c testEscalationCase3 = TestUtils.getEscalationCase(testEscalation3, testCase);

		List<rh_escal__EscalationCase__c> escalationCases = new List<rh_escal__EscalationCase__c> {
			testEscalationCase1,
			testEscalationCase2,
			testEscalationCase3
		};

		Set<Id> expectedResults = new Set<Id> {
			testEscalation1.Id,
			testEscalation2.Id,
			testEscalation3.Id
		};

		Test.startTest();

		Set<Id> results = EscalationCaseUtils.getEscalationIds(escalationCases);

		Test.stopTest();

		System.assertEquals(3, results.size(), 'Did not get the expected number of results back');

		for (Id result : results) {
			System.assert(expectedResults.contains(result), 'Got an Id back we did not expect');
			expectedResults.remove(result);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the Ids we expected');
	}

	static testMethod void buildEscalationToCaseMap() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2
		};

		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation3 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2,
			testEscalation3
		};

		rh_escal__EscalationCase__c testEscalationCase1_1 = TestUtils.getEscalationCase(testEscalation1, testCase1);
		rh_escal__EscalationCase__c testEscalationCase1_2 = TestUtils.getEscalationCase(testEscalation1, testCase2);
		rh_escal__EscalationCase__c testEscalationCase2_1 = TestUtils.getEscalationCase(testEscalation2, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2_2 = TestUtils.getEscalationCase(testEscalation2, testCase2);
		rh_escal__EscalationCase__c testEscalationCase3_1 = TestUtils.getEscalationCase(testEscalation3, testCase1);

		List<rh_escal__EscalationCase__c> escalationCases = new List<rh_escal__EscalationCase__c> {
			testEscalationCase1_1,
			testEscalationCase1_2,
			testEscalationCase2_1,
			testEscalationCase2_2,
			testEscalationCase3_1
		};

		Map<Id, Set<Id>> expectedResults = new Map<Id, Set<Id>> {
			testEscalation1.Id => new Set<Id> {
				testCase1.Id,
				testCase2.Id
			},
			testEscalation2.Id => new Set<Id> {
				testCase1.Id,
				testCase2.Id
			},
			testEscalation3.Id => new Set<Id> {
				testCase1.Id
			}
		};

		Test.startTest();

		Map<Id, List<rh_escal__EscalationCase__c>> results = EscalationCaseUtils.buildEscalationToCaseMap(escalationCases);

		Test.stopTest();

		System.assertEquals(3, results.size(), 'Did not get the expected number of results back');

		for (Id id : results.keySet()) {
			System.assertEquals(expectedResults.get(id).size(), results.get(Id).size(), 'Did not get the expected number of results back');

			for (rh_escal__EscalationCase__c result : results.get(Id)) {
				Id caseId = result.rh_escal__Case__c;
				System.assert(expectedResults.get(id).contains(caseId), 'Got an Id back we did not expect');
				expectedResults.get(id).remove(caseId);
			}

			System.assert(expectedResults.get(id).isEmpty(), 'Did not get back all the cases we expected');
			expectedResults.remove(id);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the Ids we expected');
	}

	static testMethod void getEscalationCasesForEscalations() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2
		};

		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation3 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2,
			testEscalation3
		};

		rh_escal__EscalationCase__c testEscalationCase1_1 = TestUtils.getEscalationCase(testEscalation1, testCase1);
		rh_escal__EscalationCase__c testEscalationCase1_2 = TestUtils.getEscalationCase(testEscalation1, testCase2);
		rh_escal__EscalationCase__c testEscalationCase2_1 = TestUtils.getEscalationCase(testEscalation2, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2_2 = TestUtils.getEscalationCase(testEscalation2, testCase2);
		rh_escal__EscalationCase__c testEscalationCase3_1 = TestUtils.getEscalationCase(testEscalation3, testCase1);

		List<rh_escal__EscalationCase__c> escalationCases = new List<rh_escal__EscalationCase__c> {
			testEscalationCase1_1,
			testEscalationCase1_2,
			testEscalationCase2_1,
			testEscalationCase2_2,
			testEscalationCase3_1
		};
		insert escalationCases;

		Map<Id, Set<Id>> expectedResults = new Map<Id, Set<Id>> {
			testEscalation1.Id => new Set<Id> {
				testCase1.Id,
				testCase2.Id
			},
			testEscalation2.Id => new Set<Id> {
				testCase1.Id,
				testCase2.Id
			},
			testEscalation3.Id => new Set<Id> {
				testCase1.Id
			}
		};

		Test.startTest();

		Map<Id, List<rh_escal__EscalationCase__c>> results = EscalationCaseUtils.getEscalationCasesForEscalations(expectedResults.keySet());

		Test.stopTest();

		System.assertEquals(3, results.size(), 'Did not get the expected number of results back');

		for (Id id : results.keySet()) {
			System.assertEquals(expectedResults.get(id).size(), results.get(Id).size(), 'Did not get the expected number of results back');

			for (rh_escal__EscalationCase__c result : results.get(Id)) {
				Id caseId = result.rh_escal__Case__c;
				System.assert(expectedResults.get(id).contains(caseId), 'Got an Id back we did not expect');
				expectedResults.get(id).remove(caseId);
			}

			System.assert(expectedResults.get(id).isEmpty(), 'Did not get back all the cases we expected');
			expectedResults.remove(id);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the Ids we expected');
	}
}