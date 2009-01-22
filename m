From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:10:06 +0100
Subject: [PATCH 10/14] Convert vgsplit to use vg_read_for_update.
In-Reply-To: <1232619010-4858-10-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232619010-4858-5-git-send-email-prockai@redhat.com>
	<1232619010-4858-6-git-send-email-prockai@redhat.com>
	<1232619010-4858-7-git-send-email-prockai@redhat.com>
	<1232619010-4858-8-git-send-email-prockai@redhat.com>
	<1232619010-4858-9-git-send-email-prockai@redhat.com>
	<1232619010-4858-10-git-send-email-prockai@redhat.com>
Message-ID: <1232619010-4858-11-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 15 11:02:12 CET 2009  Petr Rockai <me@mornfall.net>
  * Convert vgsplit to use vg_read_for_update.
diff -rN -u -p old-temp.4430/tools/vgsplit.c new-temp.4430/tools/vgsplit.c
--- old-temp.4430/tools/vgsplit.c	2009-01-22 11:02:50.994777933 +0100
+++ new-temp.4430/tools/vgsplit.c	2009-01-22 11:02:51.178781976 +0100
@@ -289,7 +289,6 @@ int vgsplit(struct cmd_context *cmd, int
 	struct volume_group *vg_to, *vg_from;
 	int opt;
 	int existing_vg;
-	int consistent;
 	const char *lv_name;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
@@ -320,21 +319,20 @@ int vgsplit(struct cmd_context *cmd, int
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG |
-				       RESIZEABLE_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		 return ECMD_FAILED;
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+				     REQUIRE_RESIZEABLE);
+	if (vg_read_error(vg_from))
+		return ECMD_FAILED;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vg_name_to);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
+	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, REQUIRE_RESIZEABLE |
+				   NONBLOCKING_LOCK | KEEP_LOCK |
+				   EXISTENCE_CHECK);
+
+	if (vg_read_error(vg_to))
+		goto_bad;
 
-	consistent = 0;
-	if ((vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent))) {
+	if (vg_might_exist(vg_to)) {
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -449,13 +447,14 @@ int vgsplit(struct cmd_context *cmd, int
 	/*
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
-	consistent = 1;
-	if (!test_mode() &&
-	    (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
-	     !consistent)) {
-		log_error("Volume group \"%s\" became inconsistent: please "
-			  "fix manually", vg_name_to);
-		goto_bad;
+	if (!test_mode()) {
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+					   DISABLE_LOCK | ALLOW_EXPORTED);
+		if (vg_read_error(vg_to)) {
+			log_error("Volume group \"%s\" became inconsistent: "
+				  "please fix manually", vg_name_to);
+			goto_bad;
+		}
 	}
 
 	vg_to->status &= ~EXPORTED_VG;


