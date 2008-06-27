From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jun 2008 22:35:23 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20080627223523.1133.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-27 22:35:22

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.924&r2=1.925

--- LVM2/VERSION	2008/06/27 21:56:35	1.179
+++ LVM2/VERSION	2008/06/27 22:35:22	1.180
@@ -1 +1 @@
-2.02.39-cvs (2008-06-27)
+2.02.40-cvs (2008-06-27)
--- LVM2/WHATS_NEW	2008/06/27 21:56:35	1.924
+++ LVM2/WHATS_NEW	2008/06/27 22:35:22	1.925
@@ -1,3 +1,6 @@
+Version 2.02.40 - 
+================================
+
 Version 2.02.39 - 27th June 2008
 ================================
   Enable readline by default if available.
@@ -17,12 +20,12 @@
   Fix and improve readahead 'auto' calculation for stripe_size.
   Fix lvchange output for -r auto setting if auto is already set.
   Add test case for readahead.
-  Fix ambiguous use of identifier error_message_produced.
+  Avoid ambiguous use of identifier error_message_produced.
   Begin syncing configure.in for merge/unification with device-mapper.
   Fix add_mirror_images not to dereference uninitialized log_lv upon failure.
   Don't call openlog for every debug line output by clvmd.
   Add --force to lvextend and lvresize.
-  Fix vgchange to not activate mirror leg and log volumes directly.
+  Fix vgchange not to activate component mirror volumes directly.
   Fix test directory clean up in make distclean.
 
 Version 2.02.38 - 11th June 2008


