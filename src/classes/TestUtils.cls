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

	/** The base number for an user number */
	public static Integer USER_COUNT = 0;

	/** The number that the user should be incremented by */
	public static Integer USER_INC = STANDARD_INC;

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
	* Gets a map of Profile Id to Profile
	* Sacrifices a little bit of memory for QUITE a few SOQL calls in instances where Users are created in a test
	*
	* @return the map
	*/
	public static Map<Id, Profile> PROFILE_MAP {
		get {
			if (PROFILE_MAP == null) {
				PROFILE_MAP = new Map<Id, Profile>([
					select Name
					from profile
				]);
			}

			return PROFILE_MAP;
		}
	}

	/**
	* Gets a map of Profile Name to Profile
	* Sacrifices a little bit of memory for QUITE a few SOQL calls in instances where Users are created in a test
	*
	* @return the map
	*/
	public static Map<String, Profile> PROFILE_NAME_MAP {
		get {
			if (PROFILE_NAME_MAP == null) {
				PROFILE_NAME_MAP = new Map<String, Profile>();
				for (Profile p : PROFILE_MAP.values()) {
					PROFILE_NAME_MAP.put(p.Name, p);
				}
			}
			return PROFILE_NAME_MAP;
		}
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
				rh_escal__PrimaryCase__r.AccountId,
				OwnerId,
				Owner.Name
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

	/**
	* Gets an escalation team
	*
	* @param escalation The escalation to pair
	* @return The escalation team pairing
	*/
	global static rh_escal__EscalationTeam__c getEscalationTeam(rh_escal__Escalation__c esc) {
		return new rh_escal__EscalationTeam__c(
			rh_escal__Escalation__c = esc.Id
		);
	}

	/**
	* Gets an escalation team
	*
	* @param esc The escalation, contact the type, isInternal if contact is internal
	* @return rh_escal__EscalationTeam__c object
	*/
	global static rh_escal__EscalationTeam__c getEscalationTeam(rh_escal__Escalation__c esc, Contact contact, Boolean isInternal) {
		rh_escal__EscalationTeam__c escTeam = getEscalationTeam(esc);
		escTeam.rh_escal__Contact__c = contact.Id;
		escTeam.rh_escal__Internal__c = isInternal;
		return escTeam;
	}

	/**
	* Gets an escalation team
	*
	* @param esc The escalation, user the type
	* @return rh_escal__EscalationTeam__c object
	*/
	global static rh_escal__EscalationTeam__c getEscalationTeam(rh_escal__Escalation__c esc, User user) {
		rh_escal__EscalationTeam__c escTeam = getEscalationTeam(esc);
		escTeam.rh_escal__User__c = user.Id;
		escTeam.rh_escal__Internal__c = true;
		return escTeam;
	}

	/**
	* Gets an escalation team
	*
	* @param esc The escalation, emailAdress the type
	* @return rh_escal__EscalationTeam__c object
	*/
	global static rh_escal__EscalationTeam__c getEscalationTeam(rh_escal__Escalation__c esc, String emailAddress) {
		rh_escal__EscalationTeam__c escTeam = getEscalationTeam(esc);
		escTeam.rh_escal__Email__c = emailAddress;
		return escTeam;
	}

	/**
	* Queries an escalation team
	*
	* @param escalTeam The escalation team to query
	* @return The queried escalation team
	*/
	global static rh_escal__EscalationTeam__c fetchEscalationTeam(rh_escal__EscalationTeam__c escalTeam) {
		return [
			select Name,
				rh_escal__Contact__c,
				rh_escal__Email__c,
				rh_escal__Escalation__c,
				rh_escal__Internal__c,
				rh_escal__Type__c,
				rh_escal__User__c
			from rh_escal__EscalationTeam__c
			where Id =:escalTeam.Id
		];
	}

	/**
	* Gets a contact for an account with a given lastName
	*
	* @param a An account
	* @param lName The last name
	* @return A contact
	*/
	global static Contact getContact(Account a, String lName) {
		String email = lName.replaceAll('[^a-zA-Z0-9._%+-]', '_');
		email += '@test.org';

		return new Contact(
			AccountId = a.Id,
			LastName = lName,
			Email = email
		);
	}

	/**
	* Gets an admin user
	*
	* @return An admin user
	*/
	global static User getAdminUser() {
		Profile adminProfile = PROFILE_NAME_MAP.get('System Administrator');

		User admin = [
			select Name,
				ProfileId,
				Profile.Name
			from User
			where ProfileId = :adminProfile.Id and
				isActive = true
			limit 1
		];

		return admin;
	}

	/**
	* Fetches all escalation cases for a given escalation
	*
	* @param escalation The escalation to get it's cases
	* @return The escalation cases
	*/
	global static List<rh_escal__EscalationCase__c> fetchEscalationCases(rh_escal__Escalation__c escalation) {
		return [
			select rh_escal__Case__c,
				rh_escal__Escalation__c,
				rh_escal__Primary__c
			from rh_escal__EscalationCase__c
			where rh_escal__Escalation__c = :escalation.Id
		];
	}

	/**
	* Gets an rh_escal__EscalationRouter__c based on the information provided
	*
	* @param name The escalation router name
	* @param userId The default user id
	* @return A new rh_escal__EscalationRouter__c
	*/
	global static rh_escal__EscalationRouter__c getEscalationRouter(String name, String userId) {
		return new rh_escal__EscalationRouter__c(
			Name = name,
			rh_escal__DefaultOwner__c = userId
		);
	}

	/**
	* Return a unique string.
	*
	* @param prefix is the prefix of the string to return.
	* @return a unique string.
	*/
	public static String getUniqueString(final String prefix) {
		return prefix + String.valueOf(getRandomInteger(1000000)) + Datetime.now().getTime();
	}

	/**
	* Consolidate the generation of email addresses into one location
	*
	* @param domain a domain to append to the unique email address
	* @return an email address that is unlikely to be duped
	*/
	public static String getEmailAddress(String domain) {
		return getUniqueString('testuser') + '@' + domain;
	}

	/**
	* Gets a user with the given profile and role
	*
	* @param username The username to use (must be in the form of an email)
	* @param profile The name of the profile to use
	* @return A test user
	*/
	public static User getTestUser(String username, String profile) {
		Profile currentProfile = PROFILE_NAME_MAP.get(profile);

		USER_COUNT += USER_INC;

		return new User(
			alias = 'admintes',
			email = getEmailAddress('redhat.com'),
			emailencodingkey = 'UTF-8',
			lastname = 'Testing' + String.valueOf(USER_COUNT),
			languagelocalekey = 'en_US',
			localesidkey = 'en_US',
			profileid = currentProfile.Id,
			timezonesidkey = 'America/New_York',
			username = username
		);
	}
}