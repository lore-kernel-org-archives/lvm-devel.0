From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 09:54:36 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20090410095436.17158.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 09:54:36

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Always return exit error status when locking of volume group fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1082&r2=1.1083
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/WHATS_NEW	2009/04/10 09:53:42	1.1082
+++ LVM2/WHATS_NEW	2009/04/10 09:54:36	1.1083
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Always return exit error status when locking of volume group fails.
   Fix mirror log convert validation question.
   Avoid referencing files from DESTDIR during build process.
   Avoid creating some static libraries without static_link.
--- LVM2/tools/toollib.c	2009/04/08 12:53:20	1.146
+++ LVM2/tools/toollib.c	2009/04/10 09:54:36	1.147
@@ -285,6 +285,7 @@
 			continue;	/* FIXME Unnecessary? */
 		if (!lock_vol(cmd, vgname, lock_type)) {
 			log_error("Can't lock %s: skipping", vgname);
+			ret_max = ECMD_FAILED;
 			continue;
 		}
 		if (lock_type & LCK_WRITE)
@@ -442,7 +443,7 @@
 
 	if (!lock_vol(cmd, vg_name, lock_type)) {
 		log_error("Can't lock volume group %s: skipping", vg_name);
-		return ret_max;
+		return ECMD_FAILED;
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
@@ -745,6 +746,7 @@
 			dm_list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {
 					log_error("Can't lock %s: skipping", sll->str);
+					ret_max = ECMD_FAILED;
 					continue;
 				}
 				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {


