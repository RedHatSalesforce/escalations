/**
* Testing BaseTrigger class
*
* @author Daniel Fisher (dfisher@redhat.com)
*/

@isTest
private class BaseTriggerTest {
	public class ExampleTrigger extends BaseTrigger {
		public ExampleTrigger() {}

		public ExampleTrigger(Map<Id, Account> xoldMap, List<Account> xnewObjs, Boolean isBefore) {
			super(xoldMap, xnewObjs, isBefore);
		}
	}

	static testMethod void constructor() {
		Account a = TestUtils.getAccount();

		List<Account> accounts = new List<Account> {a};
		insert accounts;

		String oldName = a.Name + '_old';

		Map<Id, Account> oldMap = new Map<Id, Account>(accounts.clone());
		oldMap.get(a.Id).Name = oldName;

		Map<Id, Account> newMap = new Map<Id, Account>(accounts);

		Test.startTest();

		ExampleTrigger bt = new ExampleTrigger(oldMap, accounts, false);

		Test.stopTest();

		System.assertEquals(oldMap.size(), bt.baseOldMap.size(), 'Did not get the expected number of objects: ' + bt.baseOldMap);
		System.assertEquals(oldName, bt.baseOldMap.get(a.Id).get('Name'), 'Did not get the expected name');
		System.assertEquals(accounts.size(), bt.baseNewObjs.size(), 'Did not get the expected number of objects: ' + bt.baseNewObjs);
		System.assertEquals(a.Name, bt.baseNewObjs.get(0).get('Name'), 'Did not get the expected name');
		System.assertEquals(newMap.size(), bt.baseNewMap.size(), 'Did not get the expected number of objects: ' + bt.baseNewMap);
		System.assertEquals(a.Name, bt.baseNewMap.get(a.Id).get('Name'), 'Did not get the expected name');
	}

	static testMethod void baseNewObjs_empty() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		Account a = TestUtils.getAccount();

		List<sObject> accounts = new List<sObject> {a};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>(accounts);
		// bt.baseNewObjs = new List<sObject>(); // done inside base class

		Test.startTest();

		System.assert(bt.baseNewObjs.isEmpty(), 'Should be empty: ' + bt.baseNewObjs);

		Test.stopTest();
	}

	static testMethod void baseNewObjs_notEmpty() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		Account a = TestUtils.getAccount();

		List<sObject> accounts = new List<sObject> {a};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>();
		bt.baseNewObjs = accounts;

		Map<Id, sObject> expectedBaseNewObjs = new Map<Id, sObject> {
			a.Id => a
		};

		Test.startTest();

		List<sObject> baseNewObjs = bt.baseNewObjs;

		Test.stopTest();

		System.assertEquals(expectedBaseNewObjs.size(), baseNewObjs.size(), 'Did not get the expected number of objects: ' + baseNewObjs);

		for (sObject account : baseNewObjs) {
			Id accountId = account.Id;
			System.assert(expectedBaseNewObjs.containsKey(accountId), 'Should contain accountId: ' + accountId);
			System.assertEquals(
				expectedBaseNewObjs.get(accountId).Id,
				accountId,
				'Unexpected value: ' + account
			);
			expectedBaseNewObjs.remove(accountId);
		}

		System.assertEquals(0, expectedBaseNewObjs.size(), 'Did not get the all the expected objects: ' + expectedBaseNewObjs);
	}

	static testMethod void baseOldMap_empty() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		Account a = TestUtils.getAccount();

		List<sObject> accounts = new List<sObject> {a};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);
		// bt.baseOldMap = new Map<Id, sObject>(); // done inside base class

		Test.startTest();

		System.assert(bt.baseOldMap.isEmpty(), 'Should be empty: ' + bt.baseOldMap);

		Test.stopTest();
	}

	static testMethod void baseOldMap_notEmpty() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		Account a = TestUtils.getAccount();

		List<sObject> accounts = new List<sObject> {a};
		insert accounts;

		bt.baseNewObjs = new List<sObject>();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Map<Id, sObject> expectedBaseOldMap = new Map<Id, sObject> {
			a.Id => a
		};

		Test.startTest();

		Map<Id, sObject> baseOldMap = bt.baseOldMap;

		Test.stopTest();

		System.assertEquals(expectedBaseOldMap.size(), baseOldMap.size(), 'Did not get the expected number of objects: ' + baseOldMap);

		for (Id accountId : baseOldMap.keySet()) {
			System.assert(expectedBaseOldMap.containsKey(accountId), 'Should contain accountId: ' + accountId);
			System.assertEquals(
				expectedBaseOldMap.get(accountId).Id,
				baseOldMap.get(accountId).Id,
				'Unexpected value: ' + baseOldMap.get(accountId)
			);
			expectedBaseOldMap.remove(accountId);
		}

		System.assertEquals(0, expectedBaseOldMap.size(), 'Did not get the all the expected objects: ' + expectedBaseOldMap);
	}

	static testMethod void baseNewMap_empty() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		Account a = TestUtils.getAccount();

		List<sObject> accounts = new List<sObject> {a};
		insert accounts;

		bt.baseNewObjs = new List<sObject>();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(bt.baseNewMap.isEmpty(), 'Should be empty: ' + bt.baseNewMap);

		Test.stopTest();
	}

	static testMethod void baseNewMap_notEmpty() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		Account a = TestUtils.getAccount();

		List<sObject> accounts = new List<sObject> {a};
		insert accounts;

		bt.baseNewObjs = accounts;
		bt.baseOldMap = new Map<Id, sObject>();

		Map<Id, sObject> expectedBaseNewMap = new Map<Id, sObject> {
			a.Id => a
		};

		Test.startTest();

		Map<Id, sObject> baseNewMap = bt.baseNewMap;

		Test.stopTest();

		System.assertEquals(expectedBaseNewMap.size(), baseNewMap.size(), 'Did not get the expected number of objects: ' + baseNewMap);

		for (Id accountId : baseNewMap.keySet()) {
			System.assert(expectedBaseNewMap.containsKey(accountId), 'Should contain accountId: ' + accountId);
			System.assertEquals(
				expectedBaseNewMap.get(accountId).Id,
				baseNewMap.get(accountId).Id,
				'Unexpected value: ' + baseNewMap.get(accountId)
			);
			expectedBaseNewMap.remove(accountId);
		}

		System.assertEquals(0, expectedBaseNewMap.size(), 'Did not get the all the expected objects: ' + expectedBaseNewMap);
	}

	static testMethod void isAfter_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = accounts;
		bt.baseOldMap = new Map<Id, sObject>();

		Test.startTest();

		System.assert(bt.isAfter, 'Should be considered isAfter');

		Test.stopTest();
	}

	static testMethod void isAfter_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = accounts;
		bt.baseOldMap = new Map<Id, sObject>();

		Test.startTest();

		System.assert(!bt.isAfter, 'Should not be considered isAfter');

		Test.stopTest();
	}

	static testMethod void isDelete_check_isDelete_before_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(bt.isDelete, 'Should be considered delete');

		Test.stopTest();
	}

	static testMethod void isActuallyUpdate_check_isDelete_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>(accounts);
		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isDelete, 'Should not be considered delete');

		Test.stopTest();
	}

	static testMethod void isActuallyInsert_check_isDelete_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);
		//bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isDelete, 'Should not be considered delete');

		Test.stopTest();
	}

	static testMethod void isDelete_check_isDelete_after_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>(accounts);
		// bt.baseNewObjs = new List<sObject>(); // implicit
		// bt.baseNewMap = new Map<Id, sObject>(); // implicit

		Test.startTest();

		System.assert(bt.isDelete, 'Should be considered delete');

		Test.stopTest();
	}

	static testMethod void isActuallyUpdate_check_isDelete_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>(accounts);
		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isDelete, 'Should not be considered delete');

		Test.stopTest();
	}

	static testMethod void isActuallyInsert_check_isDelete_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);
		//bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isDelete, 'Should not be considered delete');

		Test.stopTest();
	}

	static testMethod void isInsert_check_isInsert_before_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};

		bt.baseNewObjs = accounts;

		Test.startTest();

		System.assert(bt.isInsert, 'Should be considered insert');

		Test.stopTest();
	}

	static testMethod void isActuallyUpdate_check_isInsert_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>(accounts);
		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isInsert, 'Should not be considered insert');

		Test.stopTest();
	}

	static testMethod void isActuallyDelete_check_isInsert_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		//bt.baseNewObjs = new List<sObject>();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isInsert, 'Should not be considered insert');

		Test.stopTest();
	}

	static testMethod void isInsert_check_isInsert_after_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = accounts;

		Test.startTest();

		System.assert(bt.isInsert, 'Should be considered insert');

		Test.stopTest();
	}

	static testMethod void isActuallyUpdate_check_isInsert_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseOldMap = new Map<Id, sObject>(accounts);
		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isInsert, 'Should not be considered insert');

		Test.stopTest();
	}

	static testMethod void isActuallyDelete_check_isInsert_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		//bt.baseNewObjs = new List<sObject>(accounts);
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isInsert, 'Should not be considered insert');

		Test.stopTest();
	}

	static testMethod void isUpdate_check_isUpdate_before_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = accounts;
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(bt.isUpdate, 'Should be considered update');

		Test.stopTest();
	}

	static testMethod void isActuallyInsert_check_isUpdate_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	static testMethod void isActuallyDelete_check_isUpdate_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		bt.baseOldMap = new Map<Id, sObject>();

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	static testMethod void isUpdate_check_isUpdate_after_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = accounts;
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(bt.isUpdate, 'Should be considered update');

		Test.stopTest();
	}

	static testMethod void isActuallyInsert_check_isUpdate_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	static testMethod void isActuallyDelete_check_isUpdate_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		bt.baseOldMap = new Map<Id, sObject>();

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	static testMethod void isBulk_valid_new() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount(), TestUtils.getAccount()};

		Test.startTest();

		System.assert(bt.isBulk, 'Should be considered bulk');

		Test.stopTest();
	}

	static testMethod void isBulk_valid_update() {
		List<sObject> accounts = new List<sObject> {TestUtils.getAccount(), TestUtils.getAccount()};
		insert accounts;

		ExampleTrigger bt = new ExampleTrigger();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(bt.isBulk, 'Should be considered bulk');

		Test.stopTest();
	}

	static testMethod void isBulk_invalid_new() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		Test.startTest();

		System.assert(!bt.isBulk, 'Should not be considered bulk');

		Test.stopTest();
	}

	static testMethod void isBulk_invalid_update() {
		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		ExampleTrigger bt = new ExampleTrigger();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isBulk, 'Should not be considered bulk');

		Test.stopTest();
	}

	static testMethod void runBefore() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.runBefore();

		Test.stopTest();

		System.assertEquals(1, bt.numberOfBeforeRuns, 'Should have one run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');
	}

	static testMethod void runAfter() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.runAfter();

		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'Should have one run after');
	}

	static testMethod void run_isBefore() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.run();

		Test.stopTest();

		System.assertEquals(1, bt.numberOfBeforeRuns, 'Should have one run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should have one run after');
	}

	static testMethod void run_isAfter() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.run();

		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should have one run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'Should have one run after');
	}

	static testMethod void runWhenSkipTriggerSet() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.triggerShouldBeSkippedByDefault = true;
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.run();

		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');
	}
}