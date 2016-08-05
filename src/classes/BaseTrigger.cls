/**
* A Base trigger that other triggers can inherit from
*
* @author Daniel Fisher (dfisher@redhat.com)
* @testClasses BaseTrigger_Test
*/
public with sharing abstract class BaseTrigger {
	@TestVisible static private Map<String, TriggerInfo> triggerNameToInfoMap = new Map<String, TriggerInfo>();

	@TestVisible
	private class TriggerInfo {
		@TestVisible private String triggerClassName;
		@TestVisible private Integer numberOfBeforeRuns;
		@TestVisible private Integer numberOfAfterRuns;

		/**
		* Bare constructor
		*/
		@TestVisible
		private TriggerInfo() {
			this.numberOfBeforeRuns = 0;
			this.numberOfAfterRuns = 0;
		}

		/**
		* Constructor that takes the trigger's class name
		*
		* @param triggerClassName the name of the trigger to capture info for
		*/
		public TriggerInfo(String triggerClassName) {
			this();
			this.triggerClassName = triggerClassName;
		}

		/**
		* The trigger has been 'run-before', this object will track that running
		*/
		@TestVisible
		private void iterateRunBefore() {
			this.numberOfBeforeRuns += 1;
		}

		/**
		* The trigger has been 'run-after', this object will track that running
		*/
		@TestVisible
		private void iterateRunAfter() {
			this.numberOfAfterRuns += 1;
		}
	}

	@TestVisible protected TriggerInfo triggerInfo {
		get {
			return triggerNameToInfoMap.get(this.getTriggerName());
		}
		set;
	}

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
			return this.triggerInfo.numberOfBeforeRuns;
		}
		set;
	}

	/** The number of times the trigger has been run as an after */
	@TestVisible protected Integer numberOfAfterRuns {
		get {
			return this.triggerInfo.numberOfAfterRuns;
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

	/** The new list of objects */
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
	private BaseTrigger() {
		String triggerName = this.getTriggerName();

		if (!triggerNameToInfoMap.containsKey(triggerName)) {
			triggerNameToInfoMap.put(triggerName, new TriggerInfo(triggerName));
		}
	}

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
	* This will be overridden by a child-class
	*
	* @return a unique string that will allow the centralization of static information in the BaseTrigger class
	*/
	public abstract String getTriggerName();

	/**
	* Perform actions that should be done in the 'before' part of a trigger
	*/
	@TestVisible
	protected virtual void runBefore() {
		this.triggerInfo.iterateRunBefore();
	}

	/**
	* Perform actions that should be done in the 'after' part of a trigger
	*/
	@TestVisible
	protected virtual void runAfter() {
		this.triggerInfo.iterateRunAfter();
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