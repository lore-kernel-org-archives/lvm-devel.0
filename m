From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2010 02:14:31 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100123021431.13041.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-23 02:14:30

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.223&r2=1.224
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1406&r2=1.1407
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.340&r2=1.341

--- LVM2/VERSION	2010/01/22 01:09:09	1.223
+++ LVM2/VERSION	2010/01/23 02:14:30	1.224
@@ -1 +1 @@
-2.02.60(1)-cvs (2010-01-21)
+2.02.60(1)-cvs (2010-01-23)
--- LVM2/VERSION_DM	2010/01/22 01:09:09	1.35
+++ LVM2/VERSION_DM	2010/01/23 02:14:30	1.36
@@ -1 +1 @@
-1.02.44-cvs (2010-01-21)
+1.02.43-cvs (2010-01-23)
--- LVM2/WHATS_NEW	2010/01/22 21:59:42	1.1406
+++ LVM2/WHATS_NEW	2010/01/23 02:14:30	1.1407
@@ -1,13 +1,14 @@
-Version 2.02.60
+Version 2.02.60 - 23rd January 2010
 ===================================
-  Support "wait before testing" using '+' in pvmove and lvconvert interval.
-  Default to checking LV's progress before waiting in _wait_for_single_lv.
-  Fix syntax error in cmirror init script.
-  Eliminate extra ioctls just to check open_count in _add_new_lv_to_dtree.
-  Disable not thread-safe memory debugging if dmeventd is configured.
+  Extend cmirrord man page.
+  Sleep before first progress check if pvmove/lvconvert interval has prefix '+'.
+  Default to checking progress before waiting in _wait_for_single_lv.
+  Fix cmirror initscript (including syntax error).
+  Eliminate avoidable ioctls for checking open_count in _add_new_lv_to_dtree.
+  Disable memory debugging if dmeventd is configured. (Not thread-safe.)
   Fix first log message prefix in syslog for dmeventd plugins.
   Fix exported symbols names for dmeventd lvm2 wrapper plugin.
-  Fix failed locking messages to be more descriptive.
+  Make failed locking initialisation messages more descriptive.
 
 Version 2.02.59 - 21st January 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/01/22 01:09:09	1.340
+++ LVM2/WHATS_NEW_DM	2010/01/23 02:14:30	1.341
@@ -1,6 +1,3 @@
-Version 1.02.44
-===================================
-
 Version 1.02.43 - 21st January 2010
 ===================================
   Remove bitset, hash and pool headers superceded by libdevmapper.h.


