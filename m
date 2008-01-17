From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 15:53:01 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20080117155301.16750.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 15:53:01

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	fix default stripesize

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.765&r2=1.766
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168

--- LVM2/WHATS_NEW	2008/01/17 15:02:59	1.765
+++ LVM2/WHATS_NEW	2008/01/17 15:53:01	1.766
@@ -1,5 +1,6 @@
 Version 2.02.30 - 17th January 2008
 ===================================
+  Reinstate VG extent size and stripe size defaults (halved). (2.02.29)
   Add lists of stacked LV segments using each LV to the internal metadata.
   Change vgsplit -l (for unimplemented --list) into --maxlogicalvolumes.
   Fix process_all_pvs to detect non-orphans with no MDAs correctly.
--- LVM2/tools/lvcreate.c	2008/01/16 15:26:40	1.167
+++ LVM2/tools/lvcreate.c	2008/01/17 15:53:01	1.168
@@ -195,7 +195,7 @@
 	if (lp->stripes > 1 && !lp->stripe_size) {
 		lp->stripe_size = find_config_tree_int(cmd,
 						  "metadata/stripesize",
-						  DEFAULT_STRIPESIZE);
+						  DEFAULT_STRIPESIZE) * 2;
 		log_print("Using default stripesize %s",
 			  display_size(cmd, (uint64_t) lp->stripe_size));
 	}


