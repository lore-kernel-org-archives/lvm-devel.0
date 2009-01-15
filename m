From: Petr Rockai <me@mornfall.net>
Date: Thu, 15 Jan 2009 11:34:43 +0100
Subject: [PATCH 5/6] Convert vgsplit to use vg_read_for_update.
In-Reply-To: <1232015684-23781-5-git-send-email-me@mornfall.net>
References: <1232015684-23781-1-git-send-email-me@mornfall.net>
	<1232015684-23781-2-git-send-email-me@mornfall.net>
	<1232015684-23781-3-git-send-email-me@mornfall.net>
	<1232015684-23781-4-git-send-email-me@mornfall.net>
	<1232015684-23781-5-git-send-email-me@mornfall.net>
Message-ID: <1232015684-23781-6-git-send-email-me@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 15 11:02:12 CET 2009  Petr Rockai <me@mornfall.net>
  * Convert vgsplit to use vg_read_for_update.
diff -rN -u -p old-temp.23590/tools/vgsplit.c new-temp.23590/tools/vgsplit.c
--- old-temp.23590/tools/vgsplit.c	2009-01-15 11:27:13.963750789 +0100
+++ new-temp.23590/tools/vgsplit.c	2009-01-15 11:27:14.063752047 +0100
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


