/*
	Twitter.java
*/

package co.thinkim.twitter;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
// imports

public class Twitter extends CordovaPlugin
{
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (action.equals("requestAccess")){
			requestAccess(args, callbackContext);
		}
		else if (action.equals("accountExists")){
			accountExists(args, callbackContext);
		}
		else if (action.equals("listAccounts")){
			listAccounts(args, callbackContext);
		}
		else if (action.equals("sendDirectMessage")){
			sendDirectMessage(args, callbackContext);
		}
		else{
			// plugin failure: unrecognised command
		}
	}

	private void requestAccess(JSONArray args, CallbackContext callbackContext)
	{
		//--
	}

	private void accountExists(JSONArray args, CallbackContext callbackContext)
	{
		//--
	}

	private void listAccounts(JSONArray args, CallbackContext callbackContext)
	{
		//--
	}

	private void sendDirectMessage(JSONArray args, CallbackContext callbackContext)
	{
		//--
	}
}
