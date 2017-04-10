/**
* Test utility class
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
*/

@IsTest
global class TestUtils {
	/** The number that the identifiers should be incremented by */
	@TestVisible private static Integer STANDARD_INC = 1000000;

	/** The standard base for random numbers for identifiers */
	@TestVisible private static Integer STANDARD_RAND = 10000;

	/** The base number for an account number */
	public static Integer ACCT_COUNT = 9000000;

	/** The number that the account should be incremented by */
	public static Integer ACCT_INC = STANDARD_INC;

	/**
	* Gets a random integer
	*
	* @param base The base (or upper bounds) for the random number
	* @return A random integer between 0 and the base
	*/
	global static Integer getRandomInteger(Integer base) {
		return math.round(math.random() * base);
	}

	/**
	* Gets an account based on the information provided
	*
	* @param accountNumber The account number
	* @param name The account name
	* @return A new account
	*/
	private static Account getAccount(String accountNumber, String name) {
		return new Account(
			Name = name,
			AccountNumber = accountNumber
		);
	}

	/**
	* Gets an account with a unique account number
	*
	* @return A new account
	*/
	global static Account getAccount() {
		Integer randInt = ACCT_COUNT + getRandomInteger(STANDARD_RAND); // Should be smaller than ACCT_INC
		ACCT_COUNT += ACCT_INC;
		return getAccount(String.valueOf(randInt), '_unittest_account: ' + ACCT_COUNT);
	}

	/**
	* Gets a case for a given account
	*
	* @param account The account to pair the case to
	* @return A new Case
	*/
	global static Case getCase(Account account) {
		return new Case(
			AccountId = account.Id
		);
	}

	/**
	* Gets an escalation
	*
	* @return An escalation
	*/
	global static rh_escal__Escalation__c getEscalation() {
		return new rh_escal__Escalation__c(
			rh_escal__Subject__c = '_unittest_subject: ' + getRandomInteger(1000)
		);
	}

	/**
	* Queries an escalation
	*
	* @param escalation The escalation to query
	* @return The queried escalation
	*/
	global static rh_escal__Escalation__c fetchEscalation(rh_escal__Escalation__c escalation) {
		return [
			select rh_escal__Account__c,
				rh_escal__PrimaryCase__c,
				rh_escal__PrimaryCase__r.AccountId
			from rh_escal__Escalation__c
			where Id = :escalation.Id
		];
	}

	/**
	* Gets an escalation case pairing
	*
	* @param escalation The escalation to pair
	* @param kase The case to pair
	* @return The escalation case pairing
	*/
	global static rh_escal__EscalationCase__c getEscalationCase(rh_escal__Escalation__c escalation, Case kase) {
		return new rh_escal__EscalationCase__c(
			rh_escal__Escalation__c = escalation.Id,
			rh_escal__Case__c = kase.Id
		);
	}

	/**
	* Queries an escalation case
	*
	* @param escalationCase The escalation case to query
	* @return The queried escalation case
	*/
	global static rh_escal__EscalationCase__c fetchEscalationCase(rh_escal__EscalationCase__c escalationCase) {
		return [
			select rh_escal__Case__c,
				rh_escal__Escalation__c,
				rh_escal__Primary__c
			from rh_escal__EscalationCase__c
			where Id = :escalationCase.Id
		];
	}

	/**
	* Sets a primary case on the escalation
	*
	* @param escalation The escalation to set
	* @param kase The case to pair
	*/
	public static void setPrimaryCaseOnEscalation(rh_escal__Escalation__c escalation, Case kase) {
		escalation.rh_escal__PrimaryCase__c = kase.Id;
	}

	/**
	* Sets an account on the escalation
	*
	* @param escalation The escalation to set
	* @param acct The account to pair
	*/
	public static void setAccountOnEscalation(rh_escal__Escalation__c escalation, Account acct) {
		escalation.rh_escal__Account__c = acct.Id;
	}
}