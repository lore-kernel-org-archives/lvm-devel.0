From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 25 Oct 2010 18:02:51 -0400
Subject: [RFC][PATCH] update vgchange's handling of -a, --refresh, --monitor and --poll
Message-ID: <20101025220251.GA6858@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update vgchange to have nearly comparable processing of -a, --refresh,
--monitor and --poll

This was motivated because vgchange disallows combining --monitor and
--poll but lvm2-monitor uses: vgchange --monitor y --poll y $VGNAME

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/lvchange.c |    2 +-
 tools/vgchange.c |   35 +++++++++++++++++++++++++++++------
 2 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5ac223a..4c7578f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -715,7 +715,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lvchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	int update = /* options other than -a, --refresh or --monitor */
+	int update = /* options other than -a, --refresh, --monitor or --poll */
 		arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 92f32db..1bf4004 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -592,14 +592,40 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 						arg_int_value(cmd, poll_ARG,
 						DEFAULT_BACKGROUND_POLLING));
 
-	if (arg_count(cmd, available_ARG))
+	if (arg_count(cmd, available_ARG)) {
 		r = _vgchange_available(cmd, vg);
+		if (r != ECMD_PROCESSED)
+			return r;
+	}
 
-	else if (arg_count(cmd, monitor_ARG))
+	/* FIXME: disallow -a and --refresh (unlike lvchange)? */
+	if (arg_count(cmd, refresh_ARG)) {
+		/* refreshes the visible LVs (which starts polling) */
+		r = _vgchange_refresh(cmd, vg);
+		if (r != ECMD_PROCESSED)
+			return r;
+	}
+
+	if (!arg_count(cmd, available_ARG) &&
+	    !arg_count(cmd, refresh_ARG) &&
+	    arg_count(cmd, monitor_ARG)) {
+		/* -ay will have already done monitoring changes */
+		/* FIXME: unlike lvchange, allow --refresh and --monitor ? */
 		r = _vgchange_monitoring(cmd, vg);
+		if (r != ECMD_PROCESSED)
+			return r;
+	}
 
-	else if (arg_count(cmd, poll_ARG))
+	if (!arg_count(cmd, available_ARG) &&
+	    !arg_count(cmd, refresh_ARG) &&
+	    arg_count(cmd, poll_ARG)) {
+		/* avoid polling visible LVs multiple times (via refresh) */
+		/*
+		 * FIXME: allow --poll in conjunction with -a?
+		 * for reference: lvchange -ay also controls polling
+		 */
 		r = _vgchange_background_polling(cmd, vg);
+	}
 
 	else if (arg_count(cmd, resizeable_ARG))
 		r = _vgchange_resizeable(cmd, vg);
@@ -628,9 +654,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	else if (arg_count(cmd, clustered_ARG))
 		r = _vgchange_clustered(cmd, vg);
 
-	else if (arg_count(cmd, refresh_ARG))
-		r = _vgchange_refresh(cmd, vg);
-
 	else if (arg_count(cmd, vgmetadatacopies_ARG) ||
 		 arg_count(cmd, metadatacopies_ARG))
 		r = _vgchange_metadata_copies(cmd, vg);


