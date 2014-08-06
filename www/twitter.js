var exec = require('cordova/exec');

module.exports = {

	/*
		Triggers "Allow access Y/N" dialog
	*/
	requestAccess: function()
	{
		exec(
			null,
			null,
			"Twitter",
			"requestAccess",
			[]
		);
	},

	/*
		myName     - user_id of account to search for
		successCB  - function()
		errorCB    - function(String)
	*/
	accountExists: function(myName, successCB, errorCB)
	{
		exec(
			successCB,
			errorCB,
			"Twitter",
			"accountExists",
			[myName]
		);
	},

	/*
		successCB  - function(String[])
		errorCB    - function(String)
	*/
	listAccounts: function(successCB, errorCB)
	{
		exec(
			successCB,
			errorCB,
			"Twitter",
			"listAccounts",
			[]
		);
	},

	/*
		myName     - user_id of account to use
		targetName - user_id of receiver
		message    - message content
		successCB  - function()
		errorCB    - function(String)
	*/
    sendDirectMessage: function(myName, targetName, message, successCB, errorCB)
	{
		exec(
			successCB,
			errorCB,
			"Twitter",
			"sendDirectMessage",
			[myName, targetName, message]
		);
    }
};
