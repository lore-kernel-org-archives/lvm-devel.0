From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:43 -0400
Subject: [PATCH 06/10] Refactor vgcreate/vgextend validation of vgname/pvname(s).
In-Reply-To: <1254697907-16448-6-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-5-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Decrement argc and increment argv in a consistent way to allow for later
code-sharing.  Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgcreate.c |   11 ++++++++---
 tools/vgextend.c |   10 +++++-----
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index d171026..3d4b1b7 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -22,6 +22,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	struct volume_group *vg;
 	const char *tag;
 	const char *clustered_message = "";
+	char *vg_name;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -29,7 +30,11 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc == 1) {
+	vg_name = argv[0];
+	argc--;
+	argv++;
+
+	if (argc == 0) {
 		log_error("Please enter physical volume name(s)");
 		return EINVALID_CMD_LINE;
 	}
@@ -40,7 +45,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	vp_def.max_lv = DEFAULT_MAX_LV;
 	vp_def.alloc = DEFAULT_ALLOC_POLICY;
 	vp_def.clustered = DEFAULT_CLUSTERED;
-	if (fill_vg_create_params(cmd, argv[0], &vp_new, &vp_def))
+	if (fill_vg_create_params(cmd, vg_name, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
 	if (validate_vg_create_params(cmd, &vp_new))
@@ -63,7 +68,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc - 1, argv + 1, NULL))
+	if (!vg_extend(vg, argc, argv, NULL))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 9fa7d31..c97b3bb 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -27,15 +27,15 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc == 1) {
-		log_error("Please enter physical volume(s)");
-		return EINVALID_CMD_LINE;
-	}
-
 	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;
 
+	if (argc == 0) {
+		log_error("Please enter physical volume(s)");
+		return EINVALID_CMD_LINE;
+	}
+
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-- 
1.6.0.6


