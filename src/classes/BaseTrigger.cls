/**
* A Base trigger that other triggers can inherit from
*
* @author Daniel Fisher (dfisher@redhat.com)
* @testClasses BaseTriggerTest
*/
public with sharing virtual class BaseTrigger {
	/** If the trigger should be skipped */
	@TestVisible protected Boolean triggerShouldBeSkippedByDefault = false;

	/** If this is a before trigger */
	@TestVisible protected Boolean isBefore;

	/** If this is an after trigger */
	@TestVisible protected Boolean isAfter {
		get {
			return (!this.isBefore);
		}
		set;
	}

	/** The number of times the trigger has been run as a before */
	@TestVisible protected Integer numberOfBeforeRuns {
		get {
			if (this.numberOfBeforeRuns == null) {
				this.numberOfBeforeRuns = 0;
			}
			return this.numberOfBeforeRuns;
		}
		set;
	}

	/** The number of times the trigger has been run as an after */
	@TestVisible protected Integer numberOfAfterRuns {
		get {
			if (this.numberOfAfterRuns == null) {
				this.numberOfAfterRuns = 0;
			}
			return this.numberOfAfterRuns;
		}
		set;
	}

	/** The old map of objects */
	@TestVisible protected Map<Id, SObject> baseOldMap {
		get {
			if (this.baseOldMap == null) {
				this.baseOldMap = new Map<Id, SObject>();
			}
			return this.baseOldMap;
		}
		set;
	}

	/** The new map of objects */
	@TestVisible protected List<SObject> baseNewObjs {
		get {
			if (this.baseNewObjs == null) {
				this.baseNewObjs = new List<SObject>();
			}
			return this.baseNewObjs;
		}
		set;
	}

	/** The new map of objects */
	@TestVisible protected Map<Id, SObject> baseNewMap {
		get {
			if (this.baseNewMap == null) {
				this.baseNewMap = new Map<Id, SObject>();
				if (!isBefore && !baseNewObjs.isEmpty()) {
					this.baseNewMap = new Map<Id, SObject>(this.baseNewObjs);
				}
			}
			return this.baseNewMap;
		}
		set;
	}

	/** If the operation is a delete */
	@TestVisible protected Boolean isDelete {
		get {
			if (this.isDelete == null) {
				this.isDelete = false;
				if ((this.baseNewObjs.isEmpty()) && this.isBefore) {
					this.isDelete = true;
				}
				if ((this.baseNewMap.isEmpty()) && this.isAfter) {
					this.isDelete = true;
				}
			}
			return this.isDelete;
		}
		set;
	}

	/** If the operation is an insert */
	@TestVisible protected Boolean isInsert {
		get {
			if (this.isInsert == null) {
				this.isInsert = !(isDelete || isUpdate);
			}
			return this.isInsert;
		}
		set;
	}

	/** If the operation is an update */
	@TestVisible protected Boolean isUpdate {
		get {
			if (this.isUpdate == null) {
				this.isUpdate = !(this.isDelete || this.baseOldMap.isEmpty());
			}
			return this.isUpdate;
		}
		set;
	}

	/** If the trigger is operating on a bulk data set */
	@TestVisible protected Boolean isBulk {
		get {
			if (this.isBulk == null) {
				this.isBulk = ((this.baseNewObjs.size() > 1) || (this.baseOldMap.size() > 1));
			}
			return this.isBulk;
		}
		set;
	}

	/**
	* Bare constructor
	*/
	@TestVisible
	private BaseTrigger() {}

	/**
	* The constructor
	*
	* @param xoldMap The old map from the trigger
	* @param xnewObjs The list of new objects from the trigger
	* @param isBefore If the trigger is in before or after
	*/
	public BaseTrigger(Map<Id, SObject> xoldMap, List<SObject> xnewObjs, Boolean isBefore) {
		this();
		this.baseOldMap = xoldMap;
		this.baseNewObjs = xnewObjs;
		this.isBefore = isBefore;

		this.run();
	}

	/**
	* Perform actions that should be done in the 'before' part of a trigger
	*/
	@TestVisible
	protected virtual void runBefore() {
		this.numberOfBeforeRuns += 1;
	}

	/**
	* Perform actions that should be done in the 'after' part of a trigger
	*/
	@TestVisible
	protected virtual void runAfter() {
		this.numberOfAfterRuns += 1;
	}

	/**
	* Should the trigger be skipped?
	*
	* @return whether the entire trigger should be skipped
	*/
	@TestVisible
	protected virtual Boolean skipTrigger() {
		return this.triggerShouldBeSkippedByDefault;
	}

	/**
	* Perform trigger actions
	*/
	@TestVisible
	protected virtual void run() {
		if (this.skipTrigger()) {
			return;
		}

		if (this.isBefore) {
			this.runBefore();
		} else if (this.isAfter) {
			this.runAfter();
		}
	}
}