From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Dec 2009 19:18:36 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archive.c lib ...
Message-ID: <20091203191836.25180.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-03 19:18:34

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archive.c 
	lib/metadata   : lv_manip.c metadata.c 
	tools          : lvchange.c lvmchange.c lvresize.c pvremove.c 
	                 vgremove.c 

Log message:
	Fix tools to report error when stopped by user.
	
	(And do not produce internal error message.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1337&r2=1.1338
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.299&r2=1.300
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmchange.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2009/12/03 01:48:05	1.1337
+++ LVM2/WHATS_NEW	2009/12/03 19:18:33	1.1338
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix tools to use log_error when stopped by user.
   Fix lvcreate --readahead.
   Fix clvmd memory leak in lv_info_by_lvid.
   Do not allow creating mirrors of more than 8 images.
--- LVM2/lib/format_text/archive.c	2009/07/26 12:40:27	1.36
+++ LVM2/lib/format_text/archive.c	2009/12/03 19:18:33	1.37
@@ -317,7 +317,7 @@
 	 */
 	/* FIXME Use variation on _vg_read */
 	if (!(vg = text_vg_import_file(tf, af->path, &when, &desc))) {
-		log_print("Unable to read archive file.");
+		log_error("Unable to read archive file.");
 		tf->fmt->ops->destroy_instance(tf);
 		return;
 	}
--- LVM2/lib/metadata/lv_manip.c	2009/12/03 01:47:33	1.187
+++ LVM2/lib/metadata/lv_manip.c	2009/12/03 19:18:33	1.188
@@ -2103,7 +2103,7 @@
 				  "%slogical volume %s? [y/n]: ",
 				  vg_is_clustered(vg) ? "clustered " : "",
 				  lv->name) == 'n') {
-			log_print("Logical volume %s not removed", lv->name);
+			log_error("Logical volume %s not removed", lv->name);
 			return 0;
 		}
 	}
--- LVM2/lib/metadata/metadata.c	2009/11/24 22:55:56	1.299
+++ LVM2/lib/metadata/metadata.c	2009/12/03 19:18:34	1.300
@@ -1223,7 +1223,7 @@
 	/* prompt */
 	if (pv && !is_orphan(pv) && !pp->yes &&
 	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
-		log_print("%s: physical volume not initialized", name);
+		log_error("%s: physical volume not initialized", name);
 		return 0;
 	}
 
--- LVM2/tools/lvchange.c	2009/11/04 12:39:56	1.112
+++ LVM2/tools/lvchange.c	2009/12/03 19:18:34	1.113
@@ -183,7 +183,7 @@
 			    yes_no_prompt("Do you really want to deactivate "
 					  "logical volume %s to resync it? [y/n]: ",
 					  lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not resynced",
+				log_error("Logical volume \"%s\" not resynced",
 					  lv->name);
 				return 0;
 			}
@@ -433,7 +433,7 @@
 		    yes_no_prompt("Logical volume %s will be "
 				  "deactivated temporarily. "
 				  "Continue? [y/n]: ", lv->name) == 'n') {
-			log_print("%s device number not changed.",
+			log_error("%s device number not changed.",
 				  lv->name);
 			return 0;
 		}
--- LVM2/tools/lvmchange.c	2008/01/30 14:00:02	1.8
+++ LVM2/tools/lvmchange.c	2009/12/03 19:18:34	1.9
@@ -18,6 +18,6 @@
 int lvmchange(struct cmd_context *cmd __attribute((unused)),
 	      int argc __attribute((unused)), char **argv __attribute((unused)))
 {
-	log_print("With LVM2 and the device mapper, this program is obsolete.");
+	log_error("With LVM2 and the device mapper, this program is obsolete.");
 	return ECMD_FAILED;
 }
--- LVM2/tools/lvresize.c	2009/11/04 14:47:28	1.116
+++ LVM2/tools/lvresize.c	2009/12/03 19:18:34	1.117
@@ -120,7 +120,7 @@
 	if (!arg_count(cmd, force_ARG)) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
 				  lp->lv_name) == 'n') {
-			log_print("Logical volume %s NOT reduced", lp->lv_name);
+			log_error("Logical volume %s NOT reduced", lp->lv_name);
 			return 0;
 		}
 		if (sigint_caught())
--- LVM2/tools/pvremove.c	2009/02/25 23:29:07	1.26
+++ LVM2/tools/pvremove.c	2009/12/03 19:18:34	1.27
@@ -74,7 +74,7 @@
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
-		log_print("%s: physical volume label not removed", name);
+		log_error("%s: physical volume label not removed", name);
 		return 0;
 	}
 
--- LVM2/tools/vgremove.c	2009/09/15 01:38:59	1.57
+++ LVM2/tools/vgremove.c	2009/12/03 19:18:34	1.58
@@ -36,7 +36,7 @@
 				   "group \"%s\" containing %u "
 				   "logical volumes? [y/n]: ",
 				   vg_name, lv_count) == 'n')) {
-			log_print("Volume group \"%s\" not removed", vg_name);
+			log_error("Volume group \"%s\" not removed", vg_name);
 			return ECMD_FAILED;
 		}
 		if (!remove_lvs_in_vg(cmd, vg, force)) {


