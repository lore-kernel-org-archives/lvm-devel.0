From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:56 +0200
Subject: [PATCH 4/9] Convert vgrename to vg_read_for_update.
In-Reply-To: <1241350741-31349-4-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1241350741-31349-4-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-5-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 12:54:28 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert vgrename to vg_read_for_update.
diff -rN -u -p old-temp.31080/tools/vgrename.c new-temp.31080/tools/vgrename.c
--- old-temp.31080/tools/vgrename.c	2009-05-03 13:29:31.734236424 +0200
+++ new-temp.31080/tools/vgrename.c	2009-05-03 13:29:31.834237541 +0200
@@ -20,7 +20,6 @@ static int vg_rename_path(struct cmd_con
 {
 	char *dev_dir;
 	struct id id;
-	int consistent = 1;
 	int match = 0;
 	int found_id = 0;
 	struct dm_list *vgids;
@@ -70,25 +69,11 @@ static int vg_rename_path(struct cmd_con
 	} else
 		vgid = NULL;
 
-	if (!lock_vol(cmd, vg_name_old, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name_old);
-		return 0;
-	}
-
-	if (!(vg = vg_read_internal(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
-		log_error("Volume group %s %s%s%snot found.", vg_name_old,
-		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
-		unlock_vg(cmd, vg_name_old);
-		return 0;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | LVM_WRITE)) {
-		unlock_release_vg(cmd, vg, vg_name_old);
-		return 0;
-	}
-
-	/* Don't return failure for EXPORTED_VG */
-	vg_check_status(vg, EXPORTED_VG);
+	/* FIXME we used to print an error about EXPORTED, but proceeded
+	   nevertheless. */
+	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
+	if (vg_read_error(vg))
+		return_0;
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_release_vg(cmd, vg, vg_name_old);
@@ -100,14 +85,13 @@ static int vg_rename_path(struct cmd_con
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
-	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		unlock_release_vg(cmd, vg, vg_name_old);
-		log_error("Can't get lock for %s", vg_name_new);
-		return 0;
-	}
+	vg_new = vg_read_for_update(cmd, vg_name_new, NULL, LOCK_KEEP |
+				    READ_CHECK_EXISTENCE | LOCK_NONBLOCKING);
+
+	if (vg_read_error(vg_new))
+		goto error;
 
-	consistent = 0;
-	if ((vg_new = vg_read_internal(cmd, vg_name_new, NULL, &consistent))) {
+	if (vg_might_exist(vg_new)) {
 		log_error("New volume group \"%s\" already exists",
 			  vg_name_new);
 		goto error;


