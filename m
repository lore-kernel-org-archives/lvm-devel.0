From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jul 2010 22:52:20 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100727225220.29286.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-27 22:52:19

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.246&r2=1.247
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1672&r2=1.1673
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.396&r2=1.397

--- LVM2/VERSION	2010/07/07 02:37:28	1.246
+++ LVM2/VERSION	2010/07/27 22:52:19	1.247
@@ -1 +1 @@
-2.02.71(2)-cvs (2010-07-07)
+2.02.71(2)-cvs (2010-07-27)
--- LVM2/VERSION_DM	2010/07/07 02:37:28	1.57
+++ LVM2/VERSION_DM	2010/07/27 22:52:19	1.58
@@ -1 +1 @@
-1.02.53-cvs (2010-07-07)
+1.02.53-cvs (2010-07-27)
--- LVM2/WHATS_NEW	2010/07/27 21:57:37	1.1672
+++ LVM2/WHATS_NEW	2010/07/27 22:52:19	1.1673
@@ -1,5 +1,5 @@
-Version 2.02.71 -
-===============================
+Version 2.02.71 - 27th July 2010
+================================
   Document LVM fault handling in doc/lvm_fault_handling.txt.
   Make vgck warn about missing PVs.
   Clarify help text for vg_mda_count.
--- LVM2/WHATS_NEW_DM	2010/07/27 21:57:37	1.396
+++ LVM2/WHATS_NEW_DM	2010/07/27 22:52:19	1.397
@@ -1,5 +1,5 @@
-Version 1.02.53 -
-===============================
+Version 1.02.53 - 27th July 2010
+================================
   Switch dmeventd to use dm_create_lockfile and drop duplicate code.
   Add dm_create_lockfile to libdm to handle pidfiles for all daemons.
   Replace lookup with next in struct dfa_state & calculate states on demand.


