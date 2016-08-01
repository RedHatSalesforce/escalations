/**
* Test utility class 
*
* @author Patrick Connelly (patrick@deadlypenguin.com)
*/

@IsTest
public class TestUtils {
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
	public static Integer getRandomInteger(Integer base) {
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
	public static Account getAccount() {
		Integer randInt = ACCT_COUNT + getRandomInteger(STANDARD_RAND); // Should be smaller than ACCT_INC
		ACCT_COUNT += ACCT_INC;
		return getAccount(String.valueOf(randInt), '_unittest_account: ' + ACCT_COUNT);
	}
}