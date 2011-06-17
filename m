From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:27:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20110617142735.9185.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:27:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Remove test for status flag
	
	As the ACTIVATE_EXCL could be set only in clvmd code - there is no
	use for this test in lv_add_mirrors() function only called from
	tools context.
	
	FIXME: Add cluster test case for this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2019&r2=1.2020
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2011/06/17 14:22:48	1.2019
+++ LVM2/WHATS_NEW	2011/06/17 14:27:34	1.2020
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Remove useless test of ACTIVATE_EXCL in lv_add_mirrors() clustered code path.
   Use lv_activate_opts struct instead of MERGING status flag.
   Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag.
   Add lv_activate_opts structure for activation (replacing activation flags).
--- LVM2/lib/metadata/mirror.c	2011/06/17 14:24:18	1.153
+++ LVM2/lib/metadata/mirror.c	2011/06/17 14:27:35	1.154
@@ -2021,8 +2021,7 @@
 
 	if (vg_is_clustered(lv->vg)) {
 		/* FIXME: review check of lv_is_active_remotely */
-		if (!(lv->status & ACTIVATE_EXCL) &&
-		    !cluster_mirror_is_available(lv)) {
+		if (!cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;
 		}


