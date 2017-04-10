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
}