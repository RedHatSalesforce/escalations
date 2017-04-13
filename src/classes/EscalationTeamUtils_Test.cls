/**
* Test for the escalation team utilitites
*
* @author Preeti (ppreeti@redhat.com)
*/

@IsTest
private with sharing class EscalationTeamUtils_Test {
	static testMethod void getEscalationTeamMemberMapTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email = 'testEmail1@redhat.com';

		Contact testContact1 = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact1;

		Contact testContact2 = TestUtils.getContact(testAccount, 'testContact2');
		insert testContact2;

		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation3 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2,
			testEscalation3
		};

		Set<Id> escalationIds = new Set<Id> {
			testEscalation1.Id,
			testEscalation2.Id,
			testEscalation3.Id
		};

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation1, testContact1, true);
		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation2, testContact2, false);
		rh_escal__EscalationTeam__c testEscalationTeam3 = TestUtils.getEscalationTeam(testEscalation3, testContact2, true);

		List<rh_escal__EscalationTeam__c> escalationTeams = new List<rh_escal__EscalationTeam__c> {
			testEscalationTeam1,
			testEscalationTeam2,
			testEscalationTeam3
		};
		insert escalationTeams;

		Set<Id> expectedResults = new Set<Id> {
			testEscalationTeam1.Id,
			testEscalationTeam2.Id,
			testEscalationTeam3.Id
		};

		Test.startTest();

		Map<Id, rh_escal__EscalationTeam__c> results = EscalationTeamUtils.getEscalationTeamMemberMap(escalationIds);

		Test.stopTest();

		System.assertEquals(3, results.size(), 'Did not get the expected number of results back');
		System.assertEquals(expectedResults.size(), results.size(), 'Did not get the expected number of results back');

		for (Id teamId : results.keySet()) {
			System.assert(expectedResults.contains(teamId), 'Got an Id back we did not expect');

			expectedResults.remove(teamId);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the Ids we expected');
	}

	static testMethod void getEscalationTeamMembersTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email = 'testEmail1@redhat.com';

		Contact testContact1 = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact1;

		Contact testContact2 = TestUtils.getContact(testAccount, 'testContact2');
		insert testContact2;

		BaseTrigger.triggerNameToInfoMap.clear();

		rh_escal__Escalation__c testEscalation1 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation2 = TestUtils.getEscalation();
		rh_escal__Escalation__c testEscalation3 = TestUtils.getEscalation();

		insert new List<rh_escal__Escalation__c> {
			testEscalation1,
			testEscalation2,
			testEscalation3
		};

		testEscalation1 = TestUtils.fetchEscalation(testEscalation1);
		testEscalation2 = TestUtils.fetchEscalation(testEscalation2);
		testEscalation3 = TestUtils.fetchEscalation(testEscalation3);

		Set<Id> escalationIds = new Set<Id> {
			testEscalation1.Id,
			testEscalation2.Id,
			testEscalation3.Id
		};

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation1, testContact1, true);
		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation2, testContact2, false);
		rh_escal__EscalationTeam__c testEscalationTeam3 = TestUtils.getEscalationTeam(testEscalation3, email);

		List<rh_escal__EscalationTeam__c> escalationTeams = new List<rh_escal__EscalationTeam__c> {
			testEscalationTeam1,
			testEscalationTeam2,
			testEscalationTeam3
		};
		insert escalationTeams;

		Set<Id> expectedResults = new Set<Id> {
			testEscalationTeam1.Id,
			testEscalationTeam2.Id,
			testEscalationTeam3.Id
		};

		Test.startTest();

		List<rh_escal__EscalationTeam__c> results = EscalationTeamUtils.getEscalationTeamMembers(escalationIds);

		Test.stopTest();

		System.assertEquals(3, results.size(), 'Did not get the expected number of results back');
		System.assertEquals(expectedResults.size(), results.size(), 'Did not get the expected number of results back');

		for (rh_escal__EscalationTeam__c escalTeam : results) {
			System.assert(expectedResults.contains(escalTeam.Id), 'Got an Id back we did not expect');

			expectedResults.remove(escalTeam.Id);
		}

		System.assert(expectedResults.isEmpty(), 'Did not get back all the Ids we expected');
	}
}