From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2009 19:53:58 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20091119195358.7693.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-19 19:53:58

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.214&r2=1.215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1319&r2=1.1320
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.317&r2=1.318

--- LVM2/VERSION	2009/11/19 19:00:34	1.214
+++ LVM2/VERSION	2009/11/19 19:53:58	1.215
@@ -1 +1 @@
-2.02.55(1)-cvs (2009-11-19)
+2.02.56(1)-cvs (2009-11-19)
--- LVM2/VERSION_DM	2009/11/19 19:00:34	1.26
+++ LVM2/VERSION_DM	2009/11/19 19:53:58	1.27
@@ -1 +1 @@
-1.02.40-cvs (2009-11-19)
+1.02.41-cvs (2009-11-19)
--- LVM2/WHATS_NEW	2009/11/19 19:42:57	1.1319
+++ LVM2/WHATS_NEW	2009/11/19 19:53:58	1.1320
@@ -1,3 +1,6 @@
+Version 2.02.56 - 
+====================================
+
 Version 2.02.55 - 19th November 2009
 ====================================
   Fix deadlock when changing mirrors due to unpaired memlock refcount changes.
--- LVM2/WHATS_NEW_DM	2009/11/19 19:42:57	1.317
+++ LVM2/WHATS_NEW_DM	2009/11/19 19:53:58	1.318
@@ -1,3 +1,6 @@
+Version 1.02.41 - 
+====================================
+
 Version 1.02.40 - 19th November 2009
 ====================================
   Fix install_device-mapper Makefile target to not build dmeventd plugins.


