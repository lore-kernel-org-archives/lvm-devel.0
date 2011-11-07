From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Nov 2011 11:01:54 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20111107110154.11765.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-07 11:01:54

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Add missing default LVM_VG_NAME
	
	Add support for exported shell variable LVM_VG_NAME also
	for thins and snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2178&r2=1.2179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.245&r2=1.246

--- LVM2/WHATS_NEW	2011/11/04 22:49:53	1.2178
+++ LVM2/WHATS_NEW	2011/11/07 11:01:53	1.2179
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add missing default $LVM_VG_NAME usage for snapshots.
   Fix extent_count overflow with lvextend.
   Add missing lvrename mirrored log recursion in for_each_sub_lv.
   Improve lv_extend stack reporting.
--- LVM2/tools/lvcreate.c	2011/11/04 22:43:11	1.245
+++ LVM2/tools/lvcreate.c	2011/11/07 11:01:54	1.246
@@ -93,6 +93,9 @@
 				lp->origin = ptr + 1;
 		}
 
+		if (!lp->vg_name)
+			_set_vg_name(lp, extract_vgname(cmd, NULL));
+
 		if (!lp->vg_name) {
 			log_error("The origin name should include the "
 				  "volume group.");
@@ -111,7 +114,10 @@
 			lp->pool = vg_name;
 			if (!_set_vg_name(lp, extract_vgname(cmd, lp->pool)))
 				return_0;
-	
+
+			if (!lp->vg_name)
+				_set_vg_name(lp, extract_vgname(cmd, NULL));
+
 			if (!lp->vg_name) {
 				log_error("The pool name should include the "
 					  "volume group.");


