From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Aug 2009 21:44:39 -0000
Subject: LVM2/lib/activate fs.c
Message-ID: <20090804214439.28008.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-04 21:44:27

Modified files:
	lib/activate   : fs.c 

Log message:
	detect udev mk_link problems

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/lib/activate/fs.c	2009/08/03 18:31:53	1.45
+++ LVM2/lib/activate/fs.c	2009/08/04 21:44:20	1.46
@@ -107,7 +107,7 @@
 {
 	char lv_path[PATH_MAX], link_path[PATH_MAX], lvm1_group_path[PATH_MAX];
 	char vg_path[PATH_MAX];
-	struct stat buf;
+	struct stat buf, buf_lp;
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
@@ -161,12 +161,34 @@
 			return 0;
 		}
 
+		if (dm_udev_get_sync_support()) {
+			/* Check udev created the correct link. */
+			if (!stat(link_path, &buf_lp) &&
+			    !stat(lv_path, &buf)) {
+				if (buf_lp.st_rdev == buf.st_rdev)
+					return 1;
+				else
+					log_warn("Symlink %s that should have been "
+						 "created by udev does not have "
+						 "correct target. Falling back to "
+						 "direct link creation", lv_path);
+			} else
+				log_warn("Symlink %s that should have been "
+					 "created by udev could not be checked "
+					 "for its correctness. Falling back to "
+					 "direct link creation.", lv_path);
+
+		}
+
 		log_very_verbose("Removing %s", lv_path);
 		if (unlink(lv_path) < 0) {
 			log_sys_error("unlink", lv_path);
 			return 0;
 		}
-	}
+	} else if (dm_udev_get_sync_support())
+		log_warn("The link should had been created by udev "
+			  "but it was not found. Falling back to "
+			  "direct link creation.", lv_path);
 
 	log_very_verbose("Linking %s -> %s", lv_path, link_path);
 	if (symlink(link_path, lv_path) < 0) {


