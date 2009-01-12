From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:08:04 +0100
Subject: [PATCH 9/11] Convert vgrename to vg_read_for_update.
In-Reply-To: <1231769286-15534-9-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
	<1231769286-15534-5-git-send-email-prockai@redhat.com>
	<1231769286-15534-6-git-send-email-prockai@redhat.com>
	<1231769286-15534-7-git-send-email-prockai@redhat.com>
	<1231769286-15534-8-git-send-email-prockai@redhat.com>
	<1231769286-15534-9-git-send-email-prockai@redhat.com>
Message-ID: <1231769286-15534-10-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fri Jan  9 15:46:59 CET 2009  Petr Rockai <me@mornfall.net>
  * Convert vgrename to vg_read_for_update.
diff -rN -u -p old-lvmlib_apply/tools/vgrename.c new-lvmlib_apply/tools/vgrename.c
--- old-lvmlib_apply/tools/vgrename.c	2009-01-12 14:55:59.463015568 +0100
+++ new-lvmlib_apply/tools/vgrename.c	2009-01-12 14:55:59.555018671 +0100
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
-		unlock_vg(cmd, vg_name_old);
-		return 0;
-	}
-
-	/* Don't return failure for EXPORTED_VG */
-	vg_check_status(vg, EXPORTED_VG);
+	/* FIXME we used to print an error about EXPORTED, but proceeded
+	   nevertheless. */
+	vg = vg_read_for_update(cmd, vg_name_old, vgid, ALLOW_EXPORTED);
+	if (vg_read_error(vg))
+		return_0;
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_vg(cmd, vg_name_old);
@@ -100,14 +85,13 @@ static int vg_rename_path(struct cmd_con
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
-	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		unlock_vg(cmd, vg_name_old);
-		log_error("Can't get lock for %s", vg_name_new);
-		return 0;
-	}
+	vg_new = vg_read_for_update(cmd, vg_name_new, NULL, KEEP_LOCK |
+				    EXISTENCE_CHECK | NONBLOCKING_LOCK);
+
+	if (vg_read_error(vg_new))
+	    goto error;
 
-	consistent = 0;
-	if ((vg_new = vg_read_internal(cmd, vg_name_new, NULL, &consistent))) {
+	if (vg_might_exist(vg_new)) {
 		log_error("New volume group \"%s\" already exists",
 			  vg_name_new);
 		goto error;


