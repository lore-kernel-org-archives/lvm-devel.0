From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jul 2010 21:57:37 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM
Message-ID: <20100727215737.12389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-27 21:57:37

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1671&r2=1.1672
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.395&r2=1.396

--- LVM2/WHATS_NEW	2010/07/27 20:05:30	1.1671
+++ LVM2/WHATS_NEW	2010/07/27 21:57:37	1.1672
@@ -1,8 +1,12 @@
 Version 2.02.71 -
 ===============================
+  Document LVM fault handling in doc/lvm_fault_handling.txt.
   Make vgck warn about missing PVs.
   Clarify help text for vg_mda_count.
   Check if cluster log daemon is running before allowing cmirror create.
+  Add unit-tests dir.
+  Add configure --enable-testing and reports and report-generators dirs.
+  Correct LV list order used by lvconvert when splitting a mirror.
   Check if LV with specified name already exists when splitting a mirror.
   Fix suspend/resume logic for LVs resulting from splitting a mirror.
   Update pvcreate, {pv|vg}change, and lvm.conf man pages about metadataignore.
@@ -14,9 +18,9 @@
   Remove unnecessary includes in liblvm files.
   Use __attribute__ consistently throughout.
   Fix redundant declarations and always compile with -Wredundant-decls.
+  Fix possible hang when all mirror images of a mirrored log fail.
   Pass metadataignore to pv_create, pv_setup, _mda_setup, and add_mda.
   Init mda->list in mda_copy.
-  Fix possible hang when all mirror images of a mirrored log fail.
   Do not log backtrace in valid _lv_resume() code path.
   Cleanup help strings in configure.in.
   Prompt if metadataignore with vgextend or pvchange would adjust vg_mda_copies.
--- LVM2/WHATS_NEW_DM	2010/07/13 13:51:01	1.395
+++ LVM2/WHATS_NEW_DM	2010/07/27 21:57:37	1.396
@@ -2,6 +2,10 @@
 ===============================
   Switch dmeventd to use dm_create_lockfile and drop duplicate code.
   Add dm_create_lockfile to libdm to handle pidfiles for all daemons.
+  Replace lookup with next in struct dfa_state & calculate states on demand.
+  Improve the regex matcher, reducing the number of charset nodes used.
+  Add dm_regex_fingerprint to facilitate regex testing.
+  Skip ffs(0) in _test_word in bitset functions.
   Use "nowatch" udev rule for inappropriate devices.
 
 Version 1.02.52 - 6th July 2010


