//
//  AppDelegate.swift
//  ntfs-mount
//
//  Created by Suraj Narayanan on 22/01/15.
//  Copyright (c) 2015 Suraj Narayanan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var txtNTFSLabelName: NSTextField!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func execBash(inScript:String, isAdmin:Bool=false) -> String{
        var script = "do shell script \"\(inScript)\""
        if isAdmin{
            script += " with administrator privileges"
        }
        var appleScript = NSAppleScript(source: script)
        var eventResult = appleScript?.executeAndReturnError(nil)
        if !(eventResult != nil) {
            return "ERROR"
        }
        return "SUCCESS"
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
    
    func showPopup(statusMsg:String, infoMsg:String){
        let errPopup:NSAlert = NSAlert();
        errPopup.messageText = statusMsg
        errPopup.informativeText = infoMsg
        errPopup.runModal();
    }

    @IBAction func btnMount(sender: AnyObject) {
        let fstab_path = "/etc/fstab_fake"
        if txtNTFSLabelName.stringValue.isEmpty || txtNTFSLabelName.stringValue.utf16Count>20{
            showPopup("Error!", infoMsg: "Length of Label Name should lie between (0,20]")
            return
        }
        //Check if there is already entry for label
        let fileContent = NSString(contentsOfFile: fstab_path, encoding: NSUTF8StringEncoding, error: nil) as String
        if fileContent.rangeOfString("LABEL="+txtNTFSLabelName.stringValue)==nil{
            //If not create an entry in /etc/fstab like
            //LABEL=<ntfs_volume_label> none ntfs rw,auto,nobrowse
            var fstab_entry = "LABEL=" + txtNTFSLabelName.stringValue + " none ntfs rw,auto,nobrowse"
            execBash("echo '"+fstab_entry+"' >> "+fstab_path, isAdmin:true)
            showPopup("Success!", infoMsg: "The NTFS drive with label "+txtNTFSLabelName.stringValue+" has been mounted, click on Open Volumes button to navigate to your drive.")
        }  else {
            showPopup("Error!", infoMsg: "The NTFS drive with label "+txtNTFSLabelName.stringValue+" has already been mounted, if its plugged in just open /Volumes in Finder to access your drive.")
        }
    }
    
    @IBAction func btnOpenVolumes(sender: AnyObject) {
        execBash("open /Volumes")
    }
    
}