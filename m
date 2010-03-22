From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 22 Mar 2010 16:19:22 -0500
Subject: [PATCH] LVM: lvm.conf comment touch-ups
Message-ID: <1269292762.22490.1.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Comment touch-ups ok?

 brassow

Index: LVM2/doc/example.conf
===================================================================
--- LVM2.orig/doc/example.conf
+++ LVM2/doc/example.conf
@@ -382,8 +382,8 @@ activation {
     #
     # In the event of a failure, the specified policy will be used to determine
     # what happens. This applies to automatic repairs (when the mirror is being
-    # monitored by dmeventd) and to manual lvconvert --repair when
-    # --use-policies is given.
+    # monitored by dmeventd) and to the manually 'lvconvert --repair' when
+    # '--use-policies' is given.
     #
     # "remove" - Simply remove the faulty device and run without it.  If
     #            the log device fails, the mirror would convert to using
@@ -394,7 +394,7 @@ activation {
     #            non-mirrored device if there is only one remaining good
     #            copy.
     #
-    # "allocate" - Remove the faulty device and try to allocate space on
+    # "replace" - Remove the faulty device and try to allocate space on
     #            a new device to be a replacement for the failed device.
     #            Using this policy for the log is fast and maintains the
     #            ability to remember sync state through crashes/reboots.
@@ -403,15 +403,8 @@ activation {
     #            will preserve the mirror characteristic of the device.
     #            This policy acts like "remove" if no suitable device and
     #            space can be allocated for the replacement.
-    #
-    # "allocate_anywhere" - Not yet implemented. Useful to place the log device
-    #            temporarily on same physical volume as one of the mirror
-    #            images. This policy is not recommended for mirror devices
-    #            since it would break the redundant nature of the mirror. This
-    #            policy acts like "remove" if no suitable device and space can
-    #            be allocated for the replacement.
 
-    mirror_log_fault_policy = "allocate"
+    mirror_log_fault_policy = "replace"
     mirror_image_fault_policy = "remove"
 
     # While activating devices, I/O to devices being (re)configured is



