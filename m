From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jun 2007 19:05:03 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20070615190503.3740.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-06-15 19:05:02

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.634&r2=1.635

--- LVM2/VERSION	2007/04/27 20:58:45	1.152
+++ LVM2/VERSION	2007/06/15 19:05:02	1.153
@@ -1 +1 @@
-2.02.26-cvs (2007-04-27)
+2.02.26-cvs (2007-06-15)
--- LVM2/WHATS_NEW	2007/06/15 16:05:57	1.634
+++ LVM2/WHATS_NEW	2007/06/15 19:05:02	1.635
@@ -1,24 +1,24 @@
-Version 2.02.26 -
-=================================
+Version 2.02.26 - 15th June 2007
+================================
   Update vgcfgrestore man page.
-  Allow keyboard interrupt in user prompts where appropriate.
-  Remove system-lv code from clvmd. It's highly dodgy and never used.
-  Convert a lot of code pv dereferences to use get_pv_* functions.
-  Suppress a couple benign warnings by adding variable initializations.
+  Allow keyboard interrupt during user prompts when appropriate.
+  Remove unused clvmd system-lv code.
+  Replace many physical_volume struct dereferences with new get_pv_* functions.
+  Suppress a benign compile-time warning.
   Convert find_pv_in_vg_by_uuid and pv_create to use PV handles.
-  Add get_pv_* functions to return PV members (external LVM library).
   Add wrappers to some functions in preparation for external LVM library.
-  Allow vgcfgrestore to list metadata backup files using -f
+  Add -f to vgcfgrestore to list metadata backup files.
   Add vg_check_status to consolidate vg status checks and error messages.
   Add pvdisplay --maps implementation.
-  Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
-  Fix vgrename man page to include UUID and be consistent with lvrename.
+  Remove unsupported LVM1 options from vgcfgrestore man page.
+  Update vgcfgrestore man page to show mandatory VG name.
+  Update vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
-  Remove symlinks if parent volume is deactivated.
+  Fix deactivation code to follow dependencies and remove symlinks.
   Fix and clarify vgsplit error messages.
-  Fix a segfault if a device has no target (no table)
-  Add some more debuglogs to clvmd startup.
-  Misc clvmd cleanups
+  Fix a segfault in device_is_usable() if a device has no table.
+  Add some more debug messages to clvmd startup.
+  Misc clvmd cleanups.
 
 Version 2.02.25 - 27th April 2007
 =================================


