From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Dec 2010 17:57:16 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM ./VERSION ./VE ...
Message-ID: <20101206175716.20653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-06 17:57:15

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 
	daemons/clvmd  : lvm-functions.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1827&r2=1.1828
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.428&r2=1.429
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.262&r2=1.263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/WHATS_NEW	2010/12/06 17:37:09	1.1827
+++ LVM2/WHATS_NEW	2010/12/06 17:57:14	1.1828
@@ -1,5 +1,5 @@
-Version 2.02.78 - 
-====================================
+Version 2.02.78 - 6th December 2010
+===================================
   Abort if segment tag allocation fails in pool format _add_stripe_seg.
   Abort in _mirrored_transient_status if referenced log/image LV is not active.
   Add backtraces for dev_set() and dev_close_immediate() errors in set_lv().
--- LVM2/WHATS_NEW_DM	2010/12/06 17:37:09	1.428
+++ LVM2/WHATS_NEW_DM	2010/12/06 17:57:15	1.429
@@ -1,5 +1,5 @@
-Version 1.02.59 - 
-====================================
+Version 1.02.59 - 6th December 2010
+===================================
   Add backtraces to _process_mapper_dir and  _create_and_load_v4 error paths.
   Remove superfluous checks for NULL before calling dm_free.
 
--- LVM2/VERSION	2010/11/22 18:37:56	1.262
+++ LVM2/VERSION	2010/12/06 17:57:15	1.263
@@ -1 +1 @@
-2.02.78(2)-cvs (2010-11-22)
+2.02.78(2)-cvs (2010-12-06)
--- LVM2/VERSION_DM	2010/11/22 18:37:56	1.71
+++ LVM2/VERSION_DM	2010/12/06 17:57:15	1.72
@@ -1 +1 @@
-1.02.59-cvs (2010-11-22)
+1.02.59-cvs (2010-12-06)
--- LVM2/daemons/clvmd/lvm-functions.c	2010/12/06 17:37:09	1.102
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/12/06 17:57:15	1.103
@@ -109,7 +109,7 @@
 		break;
 	}
 
-	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s)", cmdl, command, type, scope,
+	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s%s)", cmdl, command, type, scope,
 		cmdl & LCK_NONBLOCK   ? "|NONBLOCK" : "",
 		cmdl & LCK_HOLD       ? "|HOLD" : "",
 		cmdl & LCK_LOCAL      ? "|LOCAL" : "",


