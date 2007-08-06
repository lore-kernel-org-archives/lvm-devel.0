From: meyering@sourceware.org <meyering@sourceware.org>
Date: 6 Aug 2007 14:57:49 -0000
Subject: LVM2/lib activate/dev_manager.c format_text/fo ...
Message-ID: <20070806145749.28992.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-08-06 14:57:49

Modified files:
	lib/activate   : dev_manager.c 
	lib/format_text: format-text.c 
	lib/metadata   : lv_manip.c metadata-exported.h 

Log message:
	For consistency, rename local variable: s/newname/new_name/g.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/activate/dev_manager.c	2007/07/02 11:17:21	1.125
+++ LVM2/lib/activate/dev_manager.c	2007/08/06 14:57:48	1.126
@@ -563,7 +563,7 @@
 	/* Rename? */
 		if ((suffix = strrchr(dl->dlid + sizeof(UUID_PREFIX) - 1, '-')))
 			suffix++;
-		newname = build_dm_name(dm->mem, dm->vg_name, dl->lv->name,
+		new_name = build_dm_name(dm->mem, dm->vg_name, dl->lv->name,
 					suffix);
 
 static int _belong_to_vg(const char *vgname, const char *name)
--- LVM2/lib/format_text/format-text.c	2007/07/28 12:26:21	1.79
+++ LVM2/lib/format_text/format-text.c	2007/08/06 14:57:48	1.80
@@ -939,7 +939,7 @@
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	char *slash;
-	char newname[PATH_MAX];
+	char new_name[PATH_MAX];
 	size_t len;
 
 	if (!_vg_commit_file_backup(fid, vg, mda))
@@ -953,17 +953,17 @@
 
 	if (strcmp(slash, vg->name)) {
 		len = slash - tc->path_live;
-		strncpy(newname, tc->path_live, len);
-		strcpy(newname + len, vg->name);
-		log_debug("Renaming %s to %s", tc->path_live, newname);
+		strncpy(new_name, tc->path_live, len);
+		strcpy(new_name + len, vg->name);
+		log_debug("Renaming %s to %s", tc->path_live, new_name);
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename");
 		else {
-			if (rename(tc->path_live, newname)) {
+			if (rename(tc->path_live, new_name)) {
 				log_error("%s: rename to %s failed: %s",
-					  tc->path_live, newname,
+					  tc->path_live, new_name,
 					  strerror(errno));
-				sync_dir(newname);
+				sync_dir(new_name);
 				return 0;
 			}
 		}
--- LVM2/lib/metadata/lv_manip.c	2007/08/06 09:04:21	1.117
+++ LVM2/lib/metadata/lv_manip.c	2007/08/06 14:57:48	1.118
@@ -1466,13 +1466,13 @@
  * Returns 0 on failure, 1 on success.
  */
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
-	      const char *newname)
+	      const char *new_name)
 {
 	struct volume_group *vg = lv->vg;
 
-	if (find_lv_in_vg(vg, newname)) {
+	if (find_lv_in_vg(vg, new_name)) {
 		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", newname, vg->name);
+			  "volume group \"%s\"", new_name, vg->name);
 		return 0;
 	}
 
@@ -1492,7 +1492,7 @@
 	if (!archive(vg))
 		return_0;
 
-	if (!(lv->name = dm_pool_strdup(cmd->mem, newname))) {
+	if (!(lv->name = dm_pool_strdup(cmd->mem, new_name))) {
 		log_error("Failed to allocate space for new name");
 		return 0;
 	}
--- LVM2/lib/metadata/metadata-exported.h	2007/08/06 09:04:21	1.5
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/06 14:57:48	1.6
@@ -357,7 +357,7 @@
 int lv_remove(struct logical_volume *lv);
 
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
-	      const char *newname);
+	      const char *new_name);
 
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);


