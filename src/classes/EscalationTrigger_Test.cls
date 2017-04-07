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
		testEscalation.rh_escal__PrimaryCase__c = testCase.Id;

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should not be null.');
		System.assertEquals(testEscalation.rh_escal__PrimaryCase__r.AccountId, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
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

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should be null.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The escalation account should be null.');
	}

	static testMethod void setAccountOnInsert_primaryCaseNotNull_accountNotNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		testEscalation.rh_escal__PrimaryCase__c = testCase.Id;
		testEscalation.rh_escal__Account__c = testAccount.Id;

		Test.startTest();

		insert testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should not be null.');
		System.assertEquals(testEscalation.rh_escal__PrimaryCase__r.AccountId, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
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
		testEscalation.rh_escal__PrimaryCase__c = null;
		insert testEscalation;

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should be null.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The escalation account should be null.');

		testEscalation.rh_escal__PrimaryCase__c = testCase.Id;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		system.debug(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should not be null.');
		System.assertEquals(testEscalation.rh_escal__PrimaryCase__r.AccountId, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
	}

	static testMethod void setAccountOnUpdate_primaryCaseNull_accountNotNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		testEscalation.rh_escal__PrimaryCase__c = null;
		insert testEscalation;

		testEscalation.rh_escal__Account__c = testAccount.Id;

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should be null.');
		System.assertEquals(testAccount.Id, testEscalation.rh_escal__Account__c, 'The account should not be null.');
	}

	static testMethod void setAccountOnUpdate_primaryCaseNotNull_accountNotNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation.rh_escal__PrimaryCase__c = testCase.Id;
		testEscalation.rh_escal__Account__c = testAccount.Id;

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should not be null.');
		System.assertEquals(testEscalation.rh_escal__PrimaryCase__r.AccountId, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');
	}

	static testMethod void setAccountOnUpdate_primaryCaseNull_accountNull_doNothingValidTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		testEscalation.rh_escal__PrimaryCase__c = testCase.Id;
		insert testEscalation;

		System.assertEquals(testEscalation.rh_escal__PrimaryCase__r.AccountId, testEscalation.rh_escal__Account__c, 'The primary case account should be equal to escalation account.');

		testEscalation.rh_escal__Account__c = null;
		testEscalation.rh_escal__PrimaryCase__c = null;

		Test.startTest();

		update testEscalation;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case of escalation should be null.');
		System.assertEquals(null, testEscalation.rh_escal__Account__c, 'The escalation account should be null.');
	}
}