From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2010 17:01:12 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100709170112.22886.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-09 17:01:12

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1662&r2=1.1663

--- LVM2/WHATS_NEW	2010/07/09 15:34:40	1.1662
+++ LVM2/WHATS_NEW	2010/07/09 17:01:11	1.1663
@@ -1,7 +1,11 @@
 Version 2.02.71 -
 ===============================
+  Add log_error when strdup fails in {vg|lv}_change_tag().
+  Remove unnecessary includes in liblvm files.
   Use __attribute__ consistently throughout.
   Fix redundant declarations and always compile with -Wredundant-decls.
+  Pass metadataignore to pv_create, pv_setup, _mda_setup, and add_mda.
+  Init mda->list in mda_copy.
   Fix possible hang when all mirror images of a mirrored log fail.
   Do not log backtrace in valid _lv_resume() code path.
   Cleanup help strings in configure.in.


