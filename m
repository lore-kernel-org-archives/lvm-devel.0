From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:23 -0500
Subject: [PATCH 20/21] Update vgchange tool to handle metadata balance min/max.
In-Reply-To: <1265754744-17319-20-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-16-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-17-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-18-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-19-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-20-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-21-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgchange.c |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 76 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index b4f5d00..ce1ace0 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -532,6 +532,74 @@ static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
 	return ECMD_PROCESSED;
 }
 
+static int _vgchange_metadata_balance_min(struct cmd_context *cmd,
+					  struct volume_group *vg)
+{
+	uint32_t value;
+
+	value = arg_uint_value(cmd, metadatabalancemin_ARG, 0);
+	if (value == vg_mda_balance_min(vg)) {
+		log_error("Metadata balance min of VG %s is already %u",
+			  vg->name, value);
+		return ECMD_PROCESSED;
+	}
+
+	if (!archive(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	if (!vg_set_mda_balance_min(vg, value)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	backup(vg);
+
+	log_print("Volume group \"%s\" successfully changed", vg->name);
+
+	return ECMD_PROCESSED;
+}
+
+static int _vgchange_metadata_balance_max(struct cmd_context *cmd,
+					  struct volume_group *vg)
+{
+	uint32_t value;
+
+	value = arg_uint_value(cmd, metadatabalancemax_ARG, 0);
+	if (value == vg_mda_balance_max(vg)) {
+		log_error("Metadata balance max of VG %s is already %u",
+			  vg->name, value);
+		return ECMD_PROCESSED;
+	}
+
+	if (!archive(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	if (!vg_set_mda_balance_max(vg, value)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	backup(vg);
+
+	log_print("Volume group \"%s\" successfully changed", vg->name);
+
+	return ECMD_PROCESSED;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
@@ -596,6 +664,12 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	else if (arg_count(cmd, refresh_ARG))
 		r = _vgchange_refresh(cmd, vg);
 
+	else if (arg_count(cmd, metadatabalancemin_ARG))
+		r = _vgchange_metadata_balance_min(cmd, vg);
+
+	else if (arg_count(cmd, metadatabalancemax_ARG))
+		r = _vgchange_metadata_balance_max(cmd, vg);
+
 	return r;
 }
 
@@ -609,7 +683,8 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	     arg_count(cmd, physicalextentsize_ARG) +
 	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
 	     arg_count(cmd, monitor_ARG) + arg_count(cmd, poll_ARG) +
-	     arg_count(cmd, refresh_ARG))) {
+	     arg_count(cmd, refresh_ARG) + arg_count(cmd, metadatabalancemin_ARG) +
+	     arg_count(cmd, metadatabalancemax_ARG))) {
 		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
 			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
 			  "--monitor or --poll");
-- 
1.6.0.6


