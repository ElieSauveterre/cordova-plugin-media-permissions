package com.android.plugins;

import android.Manifest;
import android.content.pm.PackageManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;
import org.apache.cordova.PermissionHelper;
import org.json.JSONException;
import org.json.JSONArray;
import org.json.JSONObject;

public class MediaPermissions extends CordovaPlugin {
    private static final String TAG = "MediaPermissions";

    private CallbackContext requestCallbackContext;

    @Override
    public void initialize(final CordovaInterface cordova, CordovaWebView webView) {
        LOG.v(TAG, "Initialize");
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        LOG.v(TAG, "Executing action: " + action);

        if ("check".equals(action)) {

            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {

                    JSONObject returnErrorObj = new JSONObject();

                    try {
                        returnErrorObj.put("error", "checking-permissions");

                        checkAction(callbackContext);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callbackContext.error(returnErrorObj);
                    }
                }
            });
            return true;
        }

        if ("request".equals(action)) {

            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {

                    JSONObject returnErrorObj = new JSONObject();

                    try {
                        returnErrorObj.put("error", "permission-denied");
                        requestMissingPermissions(callbackContext);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callbackContext.error(returnErrorObj);
                    }
                }
            });

            return true;
        }

        return false;
    }

    private void checkAction(CallbackContext callbackContext) throws JSONException {

        JSONObject returnObj = new JSONObject();

        returnObj.put("microphone", PermissionHelper.hasPermission(MediaPermissions.this, Manifest.permission.RECORD_AUDIO));
        returnObj.put("audio-settings", PermissionHelper.hasPermission(MediaPermissions.this, Manifest.permission.MODIFY_AUDIO_SETTINGS));
        returnObj.put("camera", PermissionHelper.hasPermission(MediaPermissions.this, Manifest.permission.CAMERA));

        callbackContext.success(returnObj);
    }

    private void requestMissingPermissions(CallbackContext callbackContext) throws JSONException {

        JSONObject returnObj = new JSONObject();
        requestCallbackContext = callbackContext;

        if (!PermissionHelper.hasPermission(MediaPermissions.this, Manifest.permission.RECORD_AUDIO)) {
            PermissionHelper.requestPermission(this, 1, Manifest.permission.RECORD_AUDIO);
            return;
        }

        if (!PermissionHelper.hasPermission(MediaPermissions.this, Manifest.permission.MODIFY_AUDIO_SETTINGS)) {
            PermissionHelper.requestPermission(this, 2, Manifest.permission.MODIFY_AUDIO_SETTINGS);
            return;
        }

        if (!PermissionHelper.hasPermission(MediaPermissions.this, Manifest.permission.CAMERA)) {
            PermissionHelper.requestPermission(this, 3, Manifest.permission.CAMERA);
            return;
        }

        returnObj.put("microphone", true);
        returnObj.put("audio-settings", true);
        returnObj.put("camera", true);

        callbackContext.success(returnObj);
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {

        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {

                JSONObject returnObj = new JSONObject();
                returnObj.put("error", "permission-denied");
                requestCallbackContext.error(returnObj);
                return;
            }
        }

        requestMissingPermissions(requestCallbackContext);
    }
}
