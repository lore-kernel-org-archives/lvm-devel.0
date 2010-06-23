From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jun 2010 17:48:44 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100623174844.618.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-23 17:48:43

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.240&r2=1.241
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1631&r2=1.1632
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.381&r2=1.382

--- LVM2/VERSION	2010/06/07 10:25:43	1.240
+++ LVM2/VERSION	2010/06/23 17:48:41	1.241
@@ -1 +1 @@
-2.02.68(2)-cvs (2010-06-07)
+2.02.68(2)-cvs (2010-06-23)
--- LVM2/VERSION_DM	2010/06/07 10:25:43	1.51
+++ LVM2/VERSION_DM	2010/06/23 17:48:41	1.52
@@ -1 +1 @@
-1.02.50-cvs (2010-06-07)
+1.02.50-cvs (2010-06-23)
--- LVM2/WHATS_NEW	2010/06/23 17:03:14	1.1631
+++ LVM2/WHATS_NEW	2010/06/23 17:48:41	1.1632
@@ -1,5 +1,5 @@
-Version 2.02.68 -
-===============================
+Version 2.02.68 - 23rd June 2010
+================================
   Fix clvmd initscript status to print only active clustered LVs.
   Add lv_path to reports to offer full /dev pathname.
   Fix typo in warning message about missing device with allocated data areas.
@@ -11,14 +11,13 @@
   Add man pages for lvmconf and non-existent lvmsadc and lvmsar tools.
   Exit successfully when using -o help (but not -o +help) with LVM reports.
   Do not use internal DLM lock definitions in generic LVM2 clvmd code.
-  Add dmeventd man page.
   Add --force, --nofsck and --resizefs to lvresize/extend/reduce man pages.
   Fix lvm2cmd example in documentation.
   Allow use of lvm2app and lvm2cmd headers in C++ code.
   Remove unused #includes from clvmd files and introduce clvmd-common.h.
   Move common inclusions to clvmd-common.h.
   Use #include "" for libdevmapper.h and configure.h throughout tree.
-  Fix LVM_PATH expansion when exec_prefix=NONE (2.02.67).
+  Fix LVM_PATH expansion when exec_prefix=NONE. (2.02.67)
   Fix segfault in clvmd -R if no response from daemon received.
 
 Version 2.02.67 - 4th June 2010
--- LVM2/WHATS_NEW_DM	2010/06/23 17:03:15	1.381
+++ LVM2/WHATS_NEW_DM	2010/06/23 17:48:41	1.382
@@ -1,9 +1,10 @@
-Version 1.02.50 - 
-===============================
+Version 1.02.50 - 23rd June 2010
+================================
   Fix INTERNAL_ERROR typo in ioctl iface unknown task message.
   Fix udev rules to handle spurious events properly.
   Use C99 [] not [0] in dm_ulog_request struct to avoid abort when fortified.
   Allow use of devmapper header file in C++ mode (extern "C" and __typeof__).
+  Add dmeventd man page.
 
 Version 1.02.49 - 4th June 2010
 ===============================


