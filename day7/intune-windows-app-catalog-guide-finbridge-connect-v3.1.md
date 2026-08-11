Version: v1.0
Date: 11/08/2026
Status: Draft

# Adding a Windows App to the Intune App Catalog Before Rollout

Use this guide when you need to add a Windows app to Intune before any phased rollout begins. The worked example throughout is FinBridge Connect v3.1.

1. Open the app area in the Intune admin center.
   - Sign in to the Microsoft Intune admin center.
   - Go to Apps > All apps > Add.
   - Exact labels can vary by tenant version, so verify the live menu names in your tenant before you proceed.

2. Choose the correct app type.
   - For a Windows package in .intunewin format, select Windows app (Win32). This is the correct choice for FinBridge Connect v3.1.
   - For an app from Microsoft Store, select Microsoft Store app. Some tenants may show a new Store flow or a legacy Store flow, so verify the label in your tenant.
   - For a simple link to a website or portal, select Web link.
   - Do not use a web link or Store app type for a .intunewin package.

3. Upload the FinBridge Connect package.
   - Select the FinBridge Connect v3.1 .intunewin file.
   - Complete the app wizard using the package metadata and the installation details below.

4. Fill in the App information section.
   - Name: FinBridge Connect v3.1.
   - Description: Short description of what the app does and who should use it.
   - Publisher: FinBridge.
   - Version: 3.1.
   - Use the same naming pattern that your service desk and deployment teams will recognize later.

5. Fill in the Program section.
   - Install command: FinBridgeConnect_Setup.exe /silent.
   - Uninstall command: FinBridgeConnect_Setup.exe /uninstall /silent.
   - Install behavior: choose System if the app must install in device context and all users should get it; choose User only if the vendor specifically requires per-user install.
   - For this worked example, use System unless your packaging notes say otherwise.
   - Exact field labels can vary slightly by tenant version, so verify the wizard you see in your tenant.

6. Set the Requirements section.
   - OS architecture: select the architectures the app supports, such as 64-bit only or both 32-bit and 64-bit.
   - Minimum OS version: set the lowest supported Windows version for the app.
   - Keep these requirements as tight as the vendor documentation allows so unsupported devices are filtered out early.

7. Create the Detection rules.
   - Detection rules tell Intune when installation succeeded.
   - For FinBridge Connect v3.1, use a registry detection rule.
   - Example detection target:

```text
HKLM\SOFTWARE\FinBridge\Connect
Version = 3.1
```

   - You can also detect an app by MSI product code or by file path if that is more reliable for the package you are deploying.
   - Use one rule that is stable and matches the installed state exactly. If the app can be updated in place, make sure the rule still proves version 3.1 is present.

8. Set the Return codes.
   - Return codes tell Intune how to interpret the installer exit code.
   - Treat 0 as Success.
   - Treat 3010 as Success with soft reboot required.
   - Treat 1641 as Success with hard reboot initiated if your packaging process uses that code.
   - Treat any other code as Failed unless your packaging standard says otherwise.
   - Check the Return codes page in the app wizard because the exact layout and default mapping can vary by tenant version.

9. Save the app and confirm it appears in the catalog.
   - After you finish the wizard, open the app record from Apps > All apps.
   - Confirm that the name, publisher, version, install command, uninstall command, requirements, detection rule, and return codes are all correct.
   - If the app is meant to be user-visible through Company Portal, confirm that the app is available there for the pilot group.

10. Understand the assignment types before you target any devices.
   - Required means Intune installs the app automatically on the targeted devices or users.
   - Available means the app appears in Company Portal and the user can install it themselves.
   - Uninstall means Intune removes the app from the targeted devices or users.
   - For a new application, start with a small pilot group first. Do not assign directly to the full 10,000-device fleet.
   - A pilot group helps you catch packaging errors, detection mistakes, OS compatibility problems, reboot prompts, and user-impact issues before large-scale rollout.
   - Once the pilot is stable, expand to a broader test ring, then to production rings in stages.

11. Assign the app to a small test group first.
   - Create or choose a pilot group made up of test devices or a small number of support users.
   - Assign the app as Required if you want it to install automatically on the pilot devices.
   - Use Available only if the pilot team should self-install from Company Portal.
   - Use Uninstall only when you are deliberately removing the app from a targeted group.

12. Confirm the app appears correctly in the catalog.
   - In the Intune admin center, open the app record and review the overview and properties.
   - Check that the app name is correct, the publisher is correct, the version is 3.1, and the assignment targets are the intended pilot group.
   - If the app should be available to users, confirm it is visible in Company Portal with the expected name and icon.
   - If the app does not appear where expected, verify the assignment group, assignment type, and whether the app has finished syncing to the tenant.

13. Check install status on an assigned test device.
   - On the test device, trigger a sync from Company Portal or from the work or school account settings so Intune re-evaluates the assignment.
   - In the Intune admin center, open the app and check Monitor > Device install status or the equivalent monitoring area in your tenant.
   - Review the device entry for the test machine and confirm whether Intune reports Installed, Failed, or Not applicable.
   - If the status does not update, wait for the next device check-in and sync again before changing the package.

14. Interpret the install statuses.
   - Installed means Intune detected the app successfully using the detection rule.
   - Failed means Intune tried to install the app, but the install command, return code, or detection rule did not complete as expected.
   - Not applicable means the device or user does not meet the requirements, is not targeted, or the assignment does not apply to that object.
   - If you see Not applicable on a device you expected to install, check the requirements, assignment scope, architecture, and OS version first.

15. Use the pilot results to decide the next rollout step.
   - If the pilot devices show Installed and the app behaves correctly, expand to the next ring.
   - If any pilot device shows Failed, fix the package or detection rule before expanding.
   - If pilot devices show Not applicable unexpectedly, correct the targeting or requirements before rollout.

16. Keep the rollout controlled.
   - Do not promote a new app to the full fleet until the pilot proves that install, detection, and uninstall all behave as expected.
   - Keep notes on the exact tenant labels and paths you used, because Intune UI wording can change between tenant versions.
   - For FinBridge Connect v3.1, keep the install command, uninstall command, and registry detection rule together as the package baseline for future updates.

## Quick reference for FinBridge Connect v3.1

1. App type: Windows app (Win32) for the .intunewin package.
2. Install command: FinBridgeConnect_Setup.exe /silent.
3. Uninstall command: FinBridgeConnect_Setup.exe /uninstall /silent.
4. Detection: registry key HKLM\SOFTWARE\FinBridge\Connect with Version = 3.1.
5. Pilot first: assign Required or Available to a small test group before any broad rollout.