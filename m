From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 May 2012 12:59:35 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20120523125935.31560.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-23 12:59:35

Modified files:
	doc            : example.conf.in 

Log message:
	Move thin_check_executable to proper section
	
	It's read from global section.
	In-release change, so no what's new

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/doc/example.conf.in	2012/05/14 16:29:50	1.50
+++ LVM2/doc/example.conf.in	2012/05/23 12:59:35	1.51
@@ -467,6 +467,21 @@
     # proper udev rules, all changes in block device configuration will be
     # *ignored* until a manual 'vgscan' is performed.
     use_lvmetad = 0
+
+    # Full path of the utility called to check that a thin metadata device
+    # is in a state that allows it to be used.
+    # Each time a thin pool needs to be activated or after it is deactivated
+    # this utility is executed. The activation will only proceed if the utility
+    # has an exit status of 0.
+    # Set to "" to skip this check.  (Not recommended.)
+    # The thin tools are available as part of the device-mapper-persistent-data
+    # package from https://github.com/jthornber/thin-provisioning-tools.
+    #
+    thin_check_executable = "@THIN_CHECK_CMD@"
+
+    # String with options passed with thin_check command. By default,
+    # option '-q' is for quiet output.
+    thin_check_options = [ "-q" ]
 }
 
 activation {
@@ -654,20 +669,6 @@
     thin_pool_autoextend_threshold = 100
     thin_pool_autoextend_percent = 20
 
-    # Full path of the utility called to check that a thin metadata device
-    # is in a state that allows it to be used.
-    # Each time a thin pool needs to be activated, this utility is executed.
-    # The activation will only proceed if the utility has an exit status of 0.
-    # Set to "" to skip this check.  (Not recommended.)
-    # The thin tools are available as part of the device-mapper-persistent-data
-    # package from https://github.com/jthornber/thin-provisioning-tools.
-    #
-    thin_check_executable = "@THIN_CHECK_CMD@"
-
-    # String with options passed with thin_check command. By default,
-    # option '-q' is for quiet output.
-    thin_check_options = [ "-q" ]
-
     # While activating devices, I/O to devices being (re)configured is
     # suspended, and as a precaution against deadlocks, LVM2 needs to pin
     # any memory it is using so it is not paged out.  Groups of pages that


