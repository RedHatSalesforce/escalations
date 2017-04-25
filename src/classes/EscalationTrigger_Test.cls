/**
* Test for the escalation trigger
*
* @author Preeti (ppreeti@redhat.com)
*/

@IsTest
public class EscalationTrigger_Test {
	////////////////////////////////////////////////////////////////////////////////////
	//                             setAccountOnInsert                                 //
	////////////////////////////////////////////////////////////////////////////////////
	static testMethod void setAccountOnInsert_primaryCaseNotNull_valid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');
	}

	static testMethod void setAccountOnInsert_primaryCaseNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');
	}

	static testMethod void setAccountOnInsert_primaryCaseNotNull_accountNotNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);
		TestUtils.setAccountOnEscalation(testEscalation, testAccount);

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
	}

	////////////////////////////////////////////////////////////////////////////////////
	//                             setAccountOnUpdate                                 //
	////////////////////////////////////////////////////////////////////////////////////

	static testMethod void setAccountOnUpdate_primaryCaseNotNull_valid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');

		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
	}

	static testMethod void setAccountOnUpdate_primaryCaseNull_accountNotNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		TestUtils.setAccountOnEscalation(testEscalation, testAccount);

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');
	}

	static testMethod void setAccountOnUpdate_primaryCaseNotNull_accountNotNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);
		TestUtils.setAccountOnEscalation(testEscalation, testAccount);

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
	}

	static testMethod void setAccountOnUpdate_primaryCaseNull_accountNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');

		testEscalation.rh_escal__Account__c = null;
		testEscalation.rh_escal__PrimaryCase__c = null;

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should be null.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');
	}

	////////////////////////////////////////////////////////////////////////////////////
	//                   createEscalationCaseRecordOnEscalationInsert                 //
	////////////////////////////////////////////////////////////////////////////////////

	static testMethod void createEscalationCaseRecord_primaryCaseOnEscalationNotNull_valid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		List<rh_escal__EscalationCase__c> escalCases = TestUtils.fetchEscalationCases(testEscalation);

		System.assertEquals(1, escalCases.size(), 'Did not get the expected number of cases back.');
		rh_escal__EscalationCase__c escalCase = escalCases.get(0);

		System.assertEquals(testCase.Id, escalCase.rh_escal__Case__c, 'The case id was not set correctly.');
		System.assert(escalCase.rh_escal__Primary__c, 'This should be the primary case.');
		System.assertEquals(testEscalation.Id, escalCase.rh_escal__Escalation__c, 'The escalation id was not set correctly.');
	}

	static testMethod void doNotCreateEscalationCaseRecord_primaryCaseOnEscalationNull_valid() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		List<rh_escal__EscalationCase__c> escalCases = TestUtils.fetchEscalationCases(testEscalation);

		System.assertEquals(0, escalCases.size(), 'Got the escal case that we did not expected.');
		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');
	}

	static testMethod void setPrimaryCaseNotNull_onUpdate_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		TestUtils.setPrimaryCaseOnEscalation(testEscalation, testCase);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		List<rh_escal__EscalationCase__c> escalCases = TestUtils.fetchEscalationCases(testEscalation);

		System.assertEquals(0, escalCases.size(), 'Got the escal case that we did not expected.');
		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case is not set correctly.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The account is not set correctly.');
	}
}