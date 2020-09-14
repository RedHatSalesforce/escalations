/**
* Testing BaseTrigger class
*
* @author Daniel Fisher (dfisher@redhat.com)
*/

@isTest
private class BaseTrigger_Test {
	public class ExampleTrigger extends BaseTrigger {
		public ExampleTrigger() {}

		public override String getTriggerName() {
			return 'ExampleTrigger';
		}

		public ExampleTrigger(Map<Id, Account> xoldMap, List<Account> xnewObjs, Boolean isBefore) {
			super(xoldMap, xnewObjs, isBefore);
		}
	}

	public class OtherTrigger extends BaseTrigger {
		public OtherTrigger() {}

		public override String getTriggerName() {
			return 'OtherTrigger';
		}

		public OtherTrigger(Map<Id, Account> xoldMap, List<Account> xnewObjs, Boolean isBefore) {
			super(xoldMap, xnewObjs, isBefore);
		}
	}

	@isTest
	static void TriggerInfo_baseConstructor() {
		Test.startTest();
		BaseTrigger.TriggerInfo ti = new BaseTrigger.TriggerInfo();
		Test.stopTest();

		System.assertEquals(0, ti.numberOfBeforeRuns, 'incorrect numberOfBeforeRuns');
		System.assertEquals(0, ti.numberOfAfterRuns, 'incorrect numberOfAfterRuns');
	}

	@isTest
	static void TriggerInfo_Constructor() {
		String triggerName = 'Blah';

		Test.startTest();
		BaseTrigger.TriggerInfo ti = new BaseTrigger.TriggerInfo(triggerName);
		Test.stopTest();

		System.assertEquals(0, ti.numberOfBeforeRuns, 'incorrect numberOfBeforeRuns');
		System.assertEquals(0, ti.numberOfAfterRuns, 'incorrect numberOfAfterRuns');
		System.assertEquals(triggerName, ti.triggerClassName, 'incorrect triggerClassName');
	}

	@isTest
	static void TriggerInfo_iterateRunBefore() {
		String triggerName = 'Blah';

		BaseTrigger.TriggerInfo ti = new BaseTrigger.TriggerInfo(triggerName);

		Test.startTest();
		ti.iterateRunBefore();
		Test.stopTest();

		System.assertEquals(1, ti.numberOfBeforeRuns, 'incorrect numberOfBeforeRuns');
		System.assertEquals(0, ti.numberOfAfterRuns, 'incorrect numberOfAfterRuns');
		System.assertEquals(triggerName, ti.triggerClassName, 'incorrect triggerClassName');
	}

	@isTest
	static void TriggerInfo_iterateRunAfter() {
		String triggerName = 'Blah';

		BaseTrigger.TriggerInfo ti = new BaseTrigger.TriggerInfo(triggerName);

		Test.startTest();
		ti.iterateRunAfter();
		Test.stopTest();

		System.assertEquals(0, ti.numberOfBeforeRuns, 'incorrect numberOfBeforeRuns');
		System.assertEquals(1, ti.numberOfAfterRuns, 'incorrect numberOfAfterRuns');
		System.assertEquals(triggerName, ti.triggerClassName, 'incorrect triggerClassName');
	}

	@isTest
	static void constructor() {
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

		System.assertEquals(1, bt.baseOldMap.size(), 'Did not get the expected number of objects: ' + bt.baseOldMap);
		System.assertEquals(oldName, bt.baseOldMap.get(a.Id).get('Name'), 'Did not get the expected name');
		System.assertEquals(1, bt.baseNewObjs.size(), 'Did not get the expected number of objects: ' + bt.baseNewObjs);
		System.assertEquals(a.Name, bt.baseNewObjs.get(0).get('Name'), 'Did not get the expected name');
		System.assertEquals(1, bt.baseNewMap.size(), 'Did not get the expected number of objects: ' + bt.baseNewMap);
		System.assertEquals(a.Name, bt.baseNewMap.get(a.Id).get('Name'), 'Did not get the expected name');

		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.keySet().size(), 'should be one key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('ExampleTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfBeforeRuns, 'should be no numberOfBeforeRuns');
		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfAfterRuns, 'should be one numberOfAfterRuns');
		System.assertEquals(
			'ExampleTrigger',
			BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').triggerClassName,
			'unexpected triggerClassName'
		);
	}

	@isTest
	static void baseNewObjs_empty() {
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

	@isTest
	static void baseNewObjs_notEmpty() {
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

		System.assertEquals(1, baseNewObjs.size(), 'Did not get the expected number of objects: ' + baseNewObjs);

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

	@isTest
	static void baseOldMap_empty() {
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

	@isTest
	static void baseOldMap_notEmpty() {
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

		System.assertEquals(1, baseOldMap.size(), 'Did not get the expected number of objects: ' + baseOldMap);

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

	@isTest
	static void baseNewMap_empty() {
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

	@isTest
	static void baseNewMap_notEmpty() {
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

		System.assertEquals(1, baseNewMap.size(), 'Did not get the expected number of objects: ' + baseNewMap);

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

	@isTest
	static void isAfter_valid() {
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

	@isTest
	static void isAfter_invalid() {
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

	@isTest
	static void isDelete_check_isDelete_before_valid() {
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

	@isTest
	static void isActuallyUpdate_check_isDelete_before_invalid() {
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

	@isTest
	static void isActuallyInsert_check_isDelete_before_invalid() {
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

	@isTest
	static void isDelete_check_isDelete_after_valid() {
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

	@isTest
	static void isActuallyUpdate_check_isDelete_after_invalid() {
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

	@isTest
	static void isActuallyInsert_check_isDelete_after_invalid() {
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

	@isTest
	static void isInsert_check_isInsert_before_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};

		bt.baseNewObjs = accounts;

		Test.startTest();

		System.assert(bt.isInsert, 'Should be considered insert');

		Test.stopTest();
	}

	@isTest
	static void isActuallyUpdate_check_isInsert_before_invalid() {
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

	@isTest
	static void isActuallyDelete_check_isInsert_before_invalid() {
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

	@isTest
	static void isInsert_check_isInsert_after_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = accounts;

		Test.startTest();

		System.assert(bt.isInsert, 'Should be considered insert');

		Test.stopTest();
	}

	@isTest
	static void isActuallyUpdate_check_isInsert_after_invalid() {
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

	@isTest
	static void isActuallyDelete_check_isInsert_after_invalid() {
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

	@isTest
	static void isUpdate_check_isUpdate_before_valid() {
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

	@isTest
	static void isActuallyInsert_check_isUpdate_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	@isTest
	static void isActuallyDelete_check_isUpdate_before_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;

		bt.baseOldMap = new Map<Id, sObject>();

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	@isTest
	static void isUpdate_check_isUpdate_after_valid() {
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

	@isTest
	static void isActuallyInsert_check_isUpdate_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		bt.baseNewObjs = new List<sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	@isTest
	static void isActuallyDelete_check_isUpdate_after_invalid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;

		bt.baseOldMap = new Map<Id, sObject>();

		Test.startTest();

		System.assert(!bt.isUpdate, 'Should not be considered update');

		Test.stopTest();
	}

	@isTest
	static void isBulk_valid_new() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount(), TestUtils.getAccount()};

		Test.startTest();

		System.assert(bt.isBulk, 'Should be considered bulk');

		Test.stopTest();
	}

	@isTest
	static void isBulk_valid_update() {
		List<sObject> accounts = new List<sObject> {TestUtils.getAccount(), TestUtils.getAccount()};
		insert accounts;

		ExampleTrigger bt = new ExampleTrigger();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(bt.isBulk, 'Should be considered bulk');

		Test.stopTest();
	}

	@isTest
	static void isBulk_invalid_new() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		Test.startTest();

		System.assert(!bt.isBulk, 'Should not be considered bulk');

		Test.stopTest();
	}

	@isTest
	static void isBulk_invalid_update() {
		List<sObject> accounts = new List<sObject> {TestUtils.getAccount()};
		insert accounts;

		ExampleTrigger bt = new ExampleTrigger();
		bt.baseOldMap = new Map<Id, sObject>(accounts);

		Test.startTest();

		System.assert(!bt.isBulk, 'Should not be considered bulk');

		Test.stopTest();
	}

	@isTest
	static void runBefore() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.runBefore();

		Test.stopTest();

		System.assertEquals(1, bt.numberOfBeforeRuns, 'Should have one run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.keySet().size(), 'should be one key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('ExampleTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfBeforeRuns, 'should be no numberOfBeforeRuns');
		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfAfterRuns, 'should be one numberOfAfterRuns');
		System.assertEquals(
			'ExampleTrigger',
			BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').triggerClassName,
			'unexpected triggerClassName'
		);
	}

	@isTest
	static void runAfter() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.baseNewObjs = new List<sObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'Should not have run after');

		Test.startTest();

		bt.runAfter();

		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'Should not have run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'Should have one run after');

		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.keySet().size(), 'should be one key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('ExampleTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfBeforeRuns, 'should be no numberOfBeforeRuns');
		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfAfterRuns, 'should be one numberOfAfterRuns');
		System.assertEquals(
			'ExampleTrigger',
			BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').triggerClassName,
			'unexpected triggerClassName'
		);
	}

	@isTest
	static void run_isBefore() {
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

	@isTest
	static void run_isAfter() {
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

	@isTest
	static void runWhenSkipTriggerSet() {
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

	@isTest
	static void run_twoTriggers_isBefore() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = true;
		bt.baseNewObjs = new List<SObject> {TestUtils.getAccount()};

		OtherTrigger ot = new OtherTrigger();
		ot.isBefore = true;
		ot.baseNewObjs = new List<SObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'should not have run after');

		System.assertEquals(0, ot.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(0, ot.numberOfAfterRuns, 'should not have run after');

		Test.startTest();
		bt.run();
		ot.run();
		Test.stopTest();

		System.assertEquals(1, bt.numberOfBeforeRuns, 'should have one run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'should not have run after');

		System.assertEquals(1, ot.numberOfBeforeRuns, 'should have one run before');
		System.assertEquals(0, ot.numberOfAfterRuns, 'should not have run after');

		System.assertEquals(2, BaseTrigger.triggerNameToInfoMap.keySet().size(), 'should be one key: ' + BaseTrigger.triggerNameToInfoMap);

		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('ExampleTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('OtherTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfBeforeRuns, 'should be one numberOfBeforeRuns');
		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfAfterRuns, 'should be no numberOfAfterRuns');
		System.assertEquals(
			'ExampleTrigger',
			BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').triggerClassName,
			'unexpected triggerClassName'
		);

		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('OtherTrigger').numberOfBeforeRuns, 'should be one numberOfBeforeRuns');
		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('OtherTrigger').numberOfAfterRuns, 'should be no numberOfAfterRuns');
		System.assertEquals(
			'OtherTrigger',
			BaseTrigger.triggerNameToInfoMap.get('OtherTrigger').triggerClassName,
			'unexpected triggerClassName'
		);
	}

	@isTest
	static void run_twoTriggers_isAfter() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;
		bt.baseNewObjs = new List<SObject> {TestUtils.getAccount()};

		OtherTrigger ot = new OtherTrigger();
		ot.isBefore = false;
		ot.baseNewObjs = new List<SObject> {TestUtils.getAccount()};

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(0, bt.numberOfAfterRuns, 'should not have run after');

		System.assertEquals(0, ot.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(0, ot.numberOfAfterRuns, 'should not have run after');

		Test.startTest();
		bt.run();
		ot.run();
		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'should have one run after');

		System.assertEquals(0, ot.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(1, ot.numberOfAfterRuns, 'should have one run after');

		System.assertEquals(2, BaseTrigger.triggerNameToInfoMap.keySet().size(), 'should be one key: ' + BaseTrigger.triggerNameToInfoMap);

		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('ExampleTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assert(BaseTrigger.triggerNameToInfoMap.containsKey('OtherTrigger'), 'should have key: ' + BaseTrigger.triggerNameToInfoMap);
		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfBeforeRuns, 'should be no numberOfBeforeRuns');
		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').numberOfAfterRuns, 'should be one numberOfAfterRuns');
		System.assertEquals(
			'ExampleTrigger',
			BaseTrigger.triggerNameToInfoMap.get('ExampleTrigger').triggerClassName,
			'unexpected triggerClassName'
		);

		System.assertEquals(0, BaseTrigger.triggerNameToInfoMap.get('OtherTrigger').numberOfBeforeRuns, 'should be no numberOfBeforeRuns');
		System.assertEquals(1, BaseTrigger.triggerNameToInfoMap.get('OtherTrigger').numberOfAfterRuns, 'should be one numberOfAfterRuns');
		System.assertEquals(
			'OtherTrigger',
			BaseTrigger.triggerNameToInfoMap.get('OtherTrigger').triggerClassName,
			'unexpected triggerClassName'
		);
	}

	@isTest
	static void constructor_doubleInstantiation_valid() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;
		bt.baseNewObjs = new List<SObject> {TestUtils.getAccount()};
		bt.run();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'should have one run after');

		Test.startTest();
		ExampleTrigger bt2 = new ExampleTrigger();
		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'should have one run after');

		System.assertEquals(0, bt2.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(1, bt2.numberOfAfterRuns, 'should have one run after');
	}

	@isTest
	static void constructor_doubleInstantiation_staysInSync() {
		ExampleTrigger bt = new ExampleTrigger();
		bt.isBefore = false;
		bt.baseNewObjs = new List<SObject> {TestUtils.getAccount()};
		bt.run();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(1, bt.numberOfAfterRuns, 'should have one run after');

		ExampleTrigger bt2 = new ExampleTrigger();
		bt2.isBefore = false;
		bt2.baseNewObjs = new List<SObject> {TestUtils.getAccount()};

		Test.startTest();
		bt2.run();
		Test.stopTest();

		System.assertEquals(0, bt.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(2, bt.numberOfAfterRuns, 'should have twice run after');

		System.assertEquals(0, bt2.numberOfBeforeRuns, 'should not have run before');
		System.assertEquals(2, bt2.numberOfAfterRuns, 'should have twice run after');
	}
}