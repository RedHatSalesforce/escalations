/**
* Test for the escalation case trigger
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
*/

@IsTest
private class EscalationCaseTrigger_Test {
	////////////////////////////////////////////////////////////////////////////////////
	//                             setPrimaryCaseOnInsert                             //
	////////////////////////////////////////////////////////////////////////////////////
	@isTest
	static void setPrimaryCaseOnInsert_firstCase() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase = TestUtils.getEscalationCase(testEscalation, testCase);

		Test.startTest();

		insert testEscalationCase;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase = TestUtils.fetchEscalationCase(testEscalationCase);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(testEscalationCase.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnInsert_secondCase_noOverwrite() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		insert testCase1;

		Case testCase2 = TestUtils.getCase(testAccount);
		insert testCase2;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		insert testEscalationCase1;

		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);

		Test.startTest();

		insert testEscalationCase2;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);

		System.assertEquals(testCase1.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase2.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnInsert_secondCase_newPrimary() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		insert testCase1;

		Case testCase2 = TestUtils.getCase(testAccount);
		insert testCase2;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		insert testEscalationCase1;

		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		insert testEscalationCase2;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnInsert_secondCase_newPrimaryMultiple() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);
		Case testCase3 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2,
			testCase3
		};

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		insert testEscalationCase1;

		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;

		rh_escal__EscalationCase__c testEscalationCase3 = TestUtils.getEscalationCase(testEscalation, testCase3);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		insert new List<rh_escal__EscalationCase__c> {
			testEscalationCase2,
			testEscalationCase3
		};

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
		System.assert(!testEscalationCase3.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
	}

	////////////////////////////////////////////////////////////////////////////////////
	//                             setPrimaryCaseOnDelete                             //
	////////////////////////////////////////////////////////////////////////////////////
	@isTest
	static void setPrimaryCaseOnDelete_deletePrimary() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);
		Case testCase3 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2,
			testCase3
		};

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;
		rh_escal__EscalationCase__c testEscalationCase3 = TestUtils.getEscalationCase(testEscalation, testCase3);

		insert new List<rh_escal__EscalationCase__c> {
			testEscalationCase1,
			testEscalationCase2,
			testEscalationCase3
		};

		Test.setCreatedDate(testEscalationCase3.Id, Datetime.now().addDays(-1));

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
		System.assert(!testEscalationCase3.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		delete testEscalationCase2;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase3.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase3.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnDelete_deleteNonPrimary() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		insert testCase1;

		Case testCase2 = TestUtils.getCase(testAccount);
		insert testCase2;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;

		insert new List<rh_escal__EscalationCase__c> {
			testEscalationCase1,
			testEscalationCase2
		};

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		delete testEscalationCase1;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnDelete_deleteOnlyPrimary() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase = TestUtils.getEscalationCase(testEscalation, testCase);
		testEscalationCase.rh_escal__Primary__c = true;
		insert testEscalationCase;

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase = TestUtils.fetchEscalationCase(testEscalationCase);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(testEscalationCase.rh_escal__Primary__c, 'The escalation case should have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		delete testEscalationCase;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		System.assertEquals(null, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
	}

	////////////////////////////////////////////////////////////////////////////////////
	//                             setPrimaryCaseOnUpdate                             //
	////////////////////////////////////////////////////////////////////////////////////
	@isTest
	static void setPrimaryCaseOnUpdate_removePrimary() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);
		Case testCase3 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2,
			testCase3
		};

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;
		rh_escal__EscalationCase__c testEscalationCase3 = TestUtils.getEscalationCase(testEscalation, testCase3);

		insert new List<rh_escal__EscalationCase__c> {
			testEscalationCase1,
			testEscalationCase2,
			testEscalationCase3
		};

		Test.setCreatedDate(testEscalationCase3.Id, Datetime.now().addDays(-1));

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
		System.assert(!testEscalationCase3.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		testEscalationCase2.rh_escal__Primary__c = false;

		Test.startTest();

		update testEscalationCase2;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase3.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(!testEscalationCase2.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase3.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnUpdate_setPrimary() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);
		Case testCase3 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2,
			testCase3
		};

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;
		rh_escal__EscalationCase__c testEscalationCase3 = TestUtils.getEscalationCase(testEscalation, testCase3);

		insert new List<rh_escal__EscalationCase__c> {
			testEscalationCase1,
			testEscalationCase2,
			testEscalationCase3
		};

		Test.setCreatedDate(testEscalationCase3.Id, Datetime.now().addDays(-1));

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
		System.assert(!testEscalationCase3.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		testEscalationCase3.rh_escal__Primary__c = true;

		Test.startTest();

		update testEscalationCase3;

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase3.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(!testEscalationCase2.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase3.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnUpdate_removePrimaryOnlyCase() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase = TestUtils.getEscalationCase(testEscalation, testCase);
		insert testEscalationCase;

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase = TestUtils.fetchEscalationCase(testEscalationCase);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(testEscalationCase.rh_escal__Primary__c, 'The escalation case should have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		testEscalationCase.rh_escal__Primary__c = false;

		Test.startTest();

		try {
			update testEscalationCase;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationCaseTrigger.MSG_LAST_CASE_MUST_BE_PRIMARY), 'Got the right exception type but the wrong message');
		}

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase = TestUtils.fetchEscalationCase(testEscalationCase);

		System.assertEquals(testCase.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should not have been updated');
		System.assert(testEscalationCase.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}

	@isTest
	static void setPrimaryCaseOnUpdate_noBulk() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		Case testCase2 = TestUtils.getCase(testAccount);
		Case testCase3 = TestUtils.getCase(testAccount);

		insert new List<Case> {
			testCase1,
			testCase2,
			testCase3
		};

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;
		rh_escal__EscalationCase__c testEscalationCase3 = TestUtils.getEscalationCase(testEscalation, testCase3);

		insert new List<rh_escal__EscalationCase__c> {
			testEscalationCase1,
			testEscalationCase2,
			testEscalationCase3
		};

		Test.setCreatedDate(testEscalationCase3.Id, Datetime.now().addDays(-1));

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
		System.assert(!testEscalationCase3.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');

		BaseTrigger.triggerNameToInfoMap.clear();

		testEscalationCase1.rh_escal__Primary__c = true;
		testEscalationCase2.rh_escal__Primary__c = false;

		Test.startTest();

		try {
			update new List<rh_escal__EscalationCase__c> {
				testEscalationCase1,
				testEscalationCase2
			};
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DmlException e) {
			System.assert(e.getMessage().contains(EscalationCaseTrigger.MSG_NO_BULK_UPDATE), 'Got the right exception but the wrong message');
		}

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);
		testEscalationCase3 = TestUtils.fetchEscalationCase(testEscalationCase3);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
		System.assert(!testEscalationCase3.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
	}

	/////////////////////////////////////////////////////////////////////////////////////////////
	//                     LinkExistingEscalationCaseAgainOnSameEscalation                     //
	/////////////////////////////////////////////////////////////////////////////////////////////

	@isTest
	static void setDuplicateCaseOnAnEscalation_validTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase = TestUtils.getCase(testAccount);
		insert testCase;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		testEscalation = TestUtils.fetchEscalation(testEscalation);

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase);
		insert testEscalationCase1;

		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);

		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase);

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationCase2;
			System.assert(false, 'Should have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationCaseUtils.CASE_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		System.assertEquals(null, testEscalationCase2.Id, 'The case should not have been added');
	}

	@isTest
	static void setUniqueCaseOnAnEscalation_validTest() {
		Account testAccount = TestUtils.getAccount();
		insert testAccount;

		Case testCase1 = TestUtils.getCase(testAccount);
		insert testCase1;

		Case testCase2 = TestUtils.getCase(testAccount);
		insert testCase2;

		rh_escal__Escalation__c testEscalation = TestUtils.getEscalation();
		insert testEscalation;

		rh_escal__EscalationCase__c testEscalationCase1 = TestUtils.getEscalationCase(testEscalation, testCase1);
		insert testEscalationCase1;

		rh_escal__EscalationCase__c testEscalationCase2 = TestUtils.getEscalationCase(testEscalation, testCase2);
		testEscalationCase2.rh_escal__Primary__c = true;

		BaseTrigger.triggerNameToInfoMap.clear();

		Test.startTest();

		try {
			insert testEscalationCase2;
			System.assert(true, 'Should not have thrown an exception by now');
		} catch (System.DMLException e) {
			System.assert(e.getMessage().contains(EscalationCaseUtils.CASE_ALREADY_LINKED), 'Got the right exception but the wrong message [' + e.getMessage() + ']');
		}

		Test.stopTest();

		testEscalation = TestUtils.fetchEscalation(testEscalation);
		testEscalationCase1 = TestUtils.fetchEscalationCase(testEscalationCase1);
		testEscalationCase2 = TestUtils.fetchEscalationCase(testEscalationCase2);

		System.assertEquals(testCase2.Id, testEscalation.rh_escal__PrimaryCase__c, 'The primary case should have been updated');
		System.assert(!testEscalationCase1.rh_escal__Primary__c, 'The escalation case should not have been marked as primary');
		System.assert(testEscalationCase2.rh_escal__Primary__c, 'The escalation case should have been marked as primary');
	}
}