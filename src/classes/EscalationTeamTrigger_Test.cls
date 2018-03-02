/**
* Test for the escalation team trigger
*
* @author Preeti (ppreeti@redhat.com)
*/

@IsTest
public with sharing class EscalationTeamTrigger_Test {
	////////////////////////////////////////////////////////////////////////////////////
	//                             checkTeamDuplicationOnInsert                       //
	////////////////////////////////////////////////////////////////////////////////////

	static testMethod void setDuplicateContactTypeMember_onAnEscalationTeamInsertTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, testContact, true);
		insert testEscalationTeam;

		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testContact, true);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationTeam2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assertEquals(null, testEscalationTeam2.Id, 'The team member should not have been added');
	}

	static testMethod void setUniqueContactTypeMember_onAnEscalationTeamInsertTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact1 = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact1;

		Contact testContact2 = TestUtils.getContact(testAccount, 'testContact2');
		insert testContact2;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, testContact1, true);
		insert testEscalationTeam1;

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testContact2, true);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationTeam2;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);
		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		System.assertEquals(testContact1.Id, testEscalationTeam1.rh_escal__Contact__c, 'The escalation team is not set correctly');
		System.assertEquals(testContact2.Id, testEscalationTeam2.rh_escal__Contact__c, 'The escalation team is not set correctly');
	}

	static testMethod void setDuplicateUserTypeMember_onAnEscalationTeamInsertTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		User testUser = TestUtils.getAdminUser();

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, testUser);
		insert testEscalationTeam;

		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testUser);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationTeam2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assertEquals(null, testEscalationTeam2.Id, 'The team member should not have been added');
	}

	static testMethod void setUniqueUserTypeMember_onAnEscalationTeamInsertTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		User testUser = TestUtils.getAdminUser();

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, testUser);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationTeam;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);

		System.assertEquals(testUser.Id, testEscalationTeam.rh_escal__User__c, 'The escalation team is not set correctly');
	}

	static testMethod void setDuplicateEmailTypeMember_onAnEscalationTeamInsertTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email = 'testEmail1@redHat.com';

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, email);
		insert testEscalationTeam;

		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, email);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationTeam2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assertEquals(null, testEscalationTeam2.Id, 'The team member should not have been added');
	}

	static testMethod void setUniqueEmailTypeMember_onAnEscalationTeamInsertTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email1 = 'testEmail1@redHat.com';
		String email2 = 'testEmail2@redHat.com';

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, email1);
		insert testEscalationTeam1;

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, email2);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationTeam2;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);
		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		System.assert(email1.equalsIgnoreCase(testEscalationTeam1.rh_escal__Email__c), 'The escalation team is not set correctly');
		System.assert(email2.equalsIgnoreCase(testEscalationTeam2.rh_escal__Email__c), 'The escalation team is not set correctly');
	}

	////////////////////////////////////////////////////////////////////////////////////
	//                             checkTeamDuplicationOnUpdate                       //
	////////////////////////////////////////////////////////////////////////////////////

	static testMethod void setDuplicateContactTypeMember_onAnEscalationTeamUpdateTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email1 = 'testEmail1@redHat.com';

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, testContact, true);
		insert testEscalationTeam1;

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, email1);
		insert testEscalationTeam2;

		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		testEscalationTeam2.rh_escal__Contact__c = testContact.Id;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			update testEscalationTeam2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();
	}

	static testMethod void setUniqueContactTypeMember_onAnEscalationTeamUpdateTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact1 = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact1;

		Contact testContact2 = TestUtils.getContact(testAccount, 'testContact2');
		insert testContact2;

		Contact testContact3 = TestUtils.getContact(testAccount, 'testContact3');
		insert testContact3;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, testContact1, true);
		insert testEscalationTeam1;

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testContact2, true);
		insert testEscalationTeam2;

		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		testEscalationTeam2.rh_escal__Contact__c = testContact3.Id;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			update testEscalationTeam2;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assertEquals(testContact3.Id, testEscalationTeam2.rh_escal__Contact__c, 'The team member should not have been added');
	}

	static testMethod void setDuplicateEmailTypeMember_onAnEscalationTeamUpdateTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email = 'testEmail1@redHat.com';

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, email);
		insert testEscalationTeam1;

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testContact, false);
		insert testEscalationTeam2;

		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		testEscalationTeam2.rh_escal__Email__c = email;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			update testEscalationTeam2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();
	}

	static testMethod void setUniqueEmailTypeMember_onAnEscalationTeamUpdateTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email1 = 'testEmail1@redHat.com';
		String email2 = 'testEmail2@redHat.com';

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, email1);
		insert testEscalationTeam1;

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testContact, true);
		insert testEscalationTeam2;

		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		testEscalationTeam2.rh_escal__Email__c = email2;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			update testEscalationTeam2;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assert(email2.equalsIgnoreCase(testEscalationTeam2.rh_escal__Email__c), 'The team member should not have been added');
	}

	static testMethod void setDuplicateUserTypeMember_onAnEscalationTeamUpdateTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email = 'testEmail1@redHat.com';

		User testUser = TestUtils.getAdminUser();

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, testUser);
		insert testEscalationTeam1;

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, email);
		insert testEscalationTeam2;

		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		testEscalationTeam2.rh_escal__User__c = testUser.Id;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			update testEscalationTeam2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();
	}

	static testMethod void setUniqueUserTypeMember_onAnEscalationTeamUpdateTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		User testUser = TestUtils.getAdminUser();

		String email = 'testEmail1@redHat.com';

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam1 = TestUtils.getEscalationTeam(testEscalation, email);
		insert testEscalationTeam1;

		testEscalationTeam1 = TestUtils.fetchEscalationTeam(testEscalationTeam1);

		rh_escal__EscalationTeam__c testEscalationTeam2 = TestUtils.getEscalationTeam(testEscalation, testContact, true);
		insert testEscalationTeam2;

		testEscalationTeam2 = TestUtils.fetchEscalationTeam(testEscalationTeam2);

		testEscalationTeam2.rh_escal__User__c = testUser.Id;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			update testEscalationTeam2;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationTeamUtils.TEAM_MEMBER_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assertEquals(testUser.Id, testEscalationTeam2.rh_escal__User__c, 'The team member should not have been added');
	}

	static testMethod void changeInternalDoesNotTriggerDupeExceptionForEmailContact() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		String email = 'testEmail1@redHat.com';

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, email);
		testEscalationTeam.rh_escal__Internal__c =false;
		insert testEscalationTeam;

		testEscalationTeam.rh_escal__Internal__c = true;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		update testEscalationTeam;

		Test.stopTest();

		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);
		System.assert(testEscalationTeam.rh_escal__Internal__c, 'Internal should be true');
	}

	static testMethod void changeInternalDoesNotTriggerDupeExceptionForContact() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, testContact, false);
		insert testEscalationTeam;

		testEscalationTeam.rh_escal__Internal__c = true;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		update testEscalationTeam;

		Test.stopTest();

		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);
		System.assert(testEscalationTeam.rh_escal__Internal__c, 'Internal should be true');
	}

	static testMethod void changeInternalDoesNotTriggerDupeExceptionForUser() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Contact testContact = TestUtils.getContact(testAccount, 'testContact1');
		insert testContact;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationTeam__c testEscalationTeam = TestUtils.getEscalationTeam(testEscalation, TestUtils.getAdminUser());
		testEscalationTeam.rh_escal__Internal__c =false;
		insert testEscalationTeam;

		testEscalationTeam.rh_escal__Internal__c = true;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		update testEscalationTeam;

		Test.stopTest();

		testEscalationTeam = TestUtils.fetchEscalationTeam(testEscalationTeam);
		System.assert(testEscalationTeam.rh_escal__Internal__c, 'Internal should be true');
	}
}