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

	static testMethod void checkMemberAlreadyExists_contactExists() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testContact, false);
		insert member;

		Test.StartTest();

		System.assert(EscalationTeamUtils.checkMemberAlreadyExists(member, new Set<Id> {testContact.Id}, new Set<String>()), 'We should have found an existing team member');

		Test.stopTest();
	}

	static testMethod void checkMemberAlreadyExists_userExists() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		User testUser = TestUtils.getAdminUser();

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testUser);
		insert member;

		Test.StartTest();

		System.assert(EscalationTeamUtils.checkMemberAlreadyExists(member, new Set<Id> {testUser.Id}, new Set<String>()), 'We should have found an existing team member');

		Test.stopTest();
	}

	static testMethod void checkMemberAlreadyExists_emailExists() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String emailAddress = TestUtils.getEmailAddress('redhat.com');

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, emailAddress);
		insert member;

		Test.StartTest();

		System.assert(EscalationTeamUtils.checkMemberAlreadyExists(member, new Set<Id>(), new Set<String> {emailAddress}), 'We should have found an existing email address');

		Test.stopTest();
	}

	static testMethod void checkMemberAlreadyExists_noneExist() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, TestUtils.getAdminUser());
		insert member;

		Test.StartTest();

		System.assert(!EscalationTeamUtils.checkMemberAlreadyExists(member, new Set<Id>(), new Set<String>()), 'We should not have found any matching users contacts or emails');

		Test.stopTest();
	}

	static testMethod void memberValuesChanged_contactChanged() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact1 = TestUtils.getContact(testAccount, 'testContact1');
		Contact testContact2 = TestUtils.getContact(testAccount, 'testContact2');
		insert new List<Contact> {testContact1, testContact2};

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c oldMember = TestUtils.getEscalationTeam(escal, testContact1,false);
		rh_escal__EscalationTeam__c newMember = TestUtils.getEscalationTeam(escal, testContact2,false);
		insert new List<rh_escal__EscalationTeam__c> {oldMember, newMember};

		Test.startTest();

		System.assert(EscalationTeamUtils.memberValuesChanged(new Map<Id, rh_escal__EscalationTeam__c> {newMember.Id => oldMember}, newMember), 'We should have found differences between the old and new members');

		Test.stopTest();
	}

	static testMethod void memberValuesChanged_userChanged() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c oldMember = TestUtils.getEscalationTeam(escal, TestUtils.getAdminUser());
		rh_escal__EscalationTeam__c newMember = TestUtils.getEscalationTeam(escal, TestUtils.createTestUser());
		insert new List<rh_escal__EscalationTeam__c> {oldMember, newMember};

		Test.startTest();

		System.assert(EscalationTeamUtils.memberValuesChanged(new Map<Id, rh_escal__EscalationTeam__c> {newMember.Id => oldMember}, newMember), 'We should have found differences between the old and new members');

		Test.stopTest();
	}

	static testMethod void memberValuesChanged_emailChanged() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c oldMember = TestUtils.getEscalationTeam(escal, TestUtils.getEmailAddress('test.com'));
		rh_escal__EscalationTeam__c newMember = TestUtils.getEscalationTeam(escal, TestUtils.getEmailAddress('test.com'));
		insert new List<rh_escal__EscalationTeam__c> {oldMember, newMember};

		Test.startTest();

		System.assert(EscalationTeamUtils.memberValuesChanged(new Map<Id, rh_escal__EscalationTeam__c> {newMember.Id => oldMember}, newMember), 'We should have found differences between the old and new members');

		Test.stopTest();
	}

	static testMethod void memberValuesChanged_hasContactNoChange() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testContact,false);
		insert member;

		Test.startTest();

		System.assert(!EscalationTeamUtils.memberValuesChanged(new Map<Id, rh_escal__EscalationTeam__c> {member.Id => member}, member), 'We should not have found differences between the old and new members');

		Test.stopTest();
	}

	static testMethod void memberValuesChanged_hasUserNoChange() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		User testUser = TestUtils.createTestUser();

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testUser);
		insert member;

		Test.startTest();

		System.assert(!EscalationTeamUtils.memberValuesChanged(new Map<Id, rh_escal__EscalationTeam__c> {member.Id => member}, member), 'We should have found differences between the old and new members');

		Test.stopTest();
	}

	static testMethod void memberValuesChanged_hasEmailNoChange() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String emailAddress = TestUtils.getEmailAddress('test.com');

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, emailAddress);
		insert member;

		Test.startTest();

		System.assert(!EscalationTeamUtils.memberValuesChanged(new Map<Id, rh_escal__EscalationTeam__c> {member.Id => member}, member), 'We should have found differences between the old and new members');

		Test.stopTest();
	}

	static testMethod void ensureOnlyOneContactTypeSet_oneType_User() {
		User testUser = TestUtils.createTestUser();

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testUser);

		Test.startTest();

		EscalationTeamUtils.ensureOnlyOneContactTypeSet(member);

		Test.stopTest();

		System.assert(true, 'We should not have raised any exceptions');
	}

	static testMethod void ensureOnlyOneContactTypeSet_oneType_Contact() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount ,'testContact');
		insert testContact;

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testContact, false);

		Test.startTest();

		EscalationTeamUtils.ensureOnlyOneContactTypeSet(member);

		Test.stopTest();

		System.assert(true, 'We should not have raised any exceptions');
	}

	static testMethod void ensureOnlyOneContactTypeSet_oneType_Email() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String emailAddress = TestUtils.getEmailAddress('test.com');

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, emailAddress);

		Test.startTest();

		EscalationTeamUtils.ensureOnlyOneContactTypeSet(member);

		Test.stopTest();

		System.assert(true, 'We should not have raised any exceptions');
	}

	static testMethod void ensureOnlyOneContactTypeSet_twoTypes_invalid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testcontact');
		insert testContact;

		User testUser = TestUtils.createTestUser();

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testUser);
		member.Contact__c = testContact.Id;

		Test.startTest();

		try {
			EscalationTeamUtils.ensureOnlyOneContactTypeSet(member);
			System.assert(false, 'We should have raised an exception by now');
		} catch (EscalationTeamUtils.InvalidException e) {
			System.assertEquals(EscalationTeamUtils.MSG_INVALID_TEAM_TOO_MANY_TYPES, e.getMessage(), 'Got right exception, but wrong message');
		}

		Test.stopTest();
	}

	static testMethod void ensureOnlyOneContactTypeSet_threeTypes_invalid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testcontact');
		insert testContact;

		User testUser = TestUtils.createTestUser();

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = TestUtils.getEscalationTeam(escal, testUser);
		member.Contact__c = testContact.Id;
		member.Email__c = TestUtils.getEmailAddress('test.com');

		Test.startTest();

		try {
			EscalationTeamUtils.ensureOnlyOneContactTypeSet(member);
			System.assert(false, 'We should have raised an exception by now');
		} catch (EscalationTeamUtils.InvalidException e) {
			System.assertEquals(EscalationTeamUtils.MSG_INVALID_TEAM_TOO_MANY_TYPES, e.getMessage(), 'Got right exception, but wrong message');
		}

		Test.stopTest();
	}

	static testMethod void ensureOnlyOneContactTypeSet_zeroTypes_invalid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testcontact');
		insert testContact;

		User testUser = TestUtils.createTestUser();

		rh_escal__Escalation__c escal = TestUtils.getEscalation();
		insert escal;

		rh_escal__EscalationTeam__c member = new rh_escal__EscalationTeam__c();

		Test.startTest();

		try {
			EscalationTeamUtils.ensureOnlyOneContactTypeSet(member);
			System.assert(false, 'We should have raised an exception by now');
		} catch (EscalationTeamUtils.InvalidException e) {
			System.assertEquals(EscalationTeamUtils.MSG_INVALID_TEAM_NO_TYPES, e.getMessage(), 'Got right exception, but wrong message');
		}

		Test.stopTest();
	}
}