From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2008 00:13:45 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20080126001345.612.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-26 00:13:45

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Fix internal metadata corruption in lvchange --resync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.776&r2=1.777
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/WHATS_NEW	2008/01/22 15:58:31	1.776
+++ LVM2/WHATS_NEW	2008/01/26 00:13:44	1.777
@@ -1,5 +1,6 @@
 Version 2.02.32 -
 ===================================
+  Fix internal metadata corruption in lvchange --resync. (2.02.30)
   Fix new parameter validation in vgsplit and test mode. (2.02.30)
   Remove redundant cnxman-socket.h file from clvmd directory.
   Fix pvs, vgs, lvs error exit status on some error paths.
--- LVM2/tools/lvchange.c	2008/01/10 18:35:51	1.85
+++ LVM2/tools/lvchange.c	2008/01/26 00:13:45	1.86
@@ -274,6 +274,7 @@
 		first_seg(lv)->log_lv = NULL;
 		log_lv->status &= ~MIRROR_LOG;
 		log_lv->status |= VISIBLE_LV;
+		remove_seg_from_segs_using_this_lv(log_lv, first_seg(lv));
 
 		if (!vg_write(lv->vg)) {
 			log_error("Failed to write intermediate VG metadata.");
@@ -281,6 +282,7 @@
 				first_seg(lv)->log_lv = log_lv;
 				log_lv->status |= MIRROR_LOG;
 				log_lv->status &= ~VISIBLE_LV;
+				add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
 				if (!activate_lv(cmd, lv))
 					stack;
 			}
@@ -295,6 +297,7 @@
 				first_seg(lv)->log_lv = log_lv;
 				log_lv->status |= MIRROR_LOG;
 				log_lv->status &= ~VISIBLE_LV;
+				add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
 				if (!activate_lv(cmd, lv))
 					stack;
 			}
@@ -326,6 +329,7 @@
 		first_seg(lv)->log_lv = log_lv;
 		log_lv->status |= MIRROR_LOG;
 		log_lv->status &= ~VISIBLE_LV;
+		add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);


