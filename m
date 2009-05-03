From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:58 +0200
Subject: [PATCH 6/9] Convert vgsplit to use vg_read_for_update.
In-Reply-To: <1241350741-31349-6-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1241350741-31349-4-git-send-email-prockai@redhat.com>
	<1241350741-31349-5-git-send-email-prockai@redhat.com>
	<1241350741-31349-6-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-7-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 13:12:28 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert vgsplit to use vg_read_for_update.
diff -rN -u -p old-temp.31080/tools/vgsplit.c new-temp.31080/tools/vgsplit.c
--- old-temp.31080/tools/vgsplit.c	2009-05-03 13:29:35.650236640 +0200
+++ new-temp.31080/tools/vgsplit.c	2009-05-03 13:29:35.758243454 +0200
@@ -289,7 +289,6 @@ int vgsplit(struct cmd_context *cmd, int
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
 	int existing_vg;
-	int consistent;
 	int r = ECMD_FAILED;
 	const char *lv_name;
 
@@ -321,21 +320,22 @@ int vgsplit(struct cmd_context *cmd, int
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG |
-				       RESIZEABLE_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		 return ECMD_FAILED;
 
-	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vg_name_to);
-		unlock_release_vg(cmd, vg_from, vg_name_from);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+				     READ_REQUIRE_RESIZEABLE);
+	if (vg_read_error(vg_from))
 		return ECMD_FAILED;
-	}
 
-	consistent = 0;
-	if ((vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent))) {
+	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
+	vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+				   READ_REQUIRE_RESIZEABLE |
+				   LOCK_NONBLOCKING | LOCK_KEEP |
+				   READ_CHECK_EXISTENCE);
+
+	if (vg_read_error(vg_to))
+		goto_bad;
+
+	if (vg_might_exist(vg_to)) {
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -448,13 +448,12 @@ int vgsplit(struct cmd_context *cmd, int
 	/*
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
-	consistent = 1;
 	if (!test_mode()) {
-		vg_release(vg_to);
-		if (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
-		    !consistent) {
-			log_error("Volume group \"%s\" became inconsistent: please "
-				  "fix manually", vg_name_to);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+					   READ_ALLOW_EXPORTED);
+		if (vg_read_error(vg_to)) {
+			log_error("Volume group \"%s\" became inconsistent: "
+				  "please fix manually", vg_name_to);
 			goto_bad;
 		}
 	}


