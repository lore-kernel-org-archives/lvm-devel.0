From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:27:02 -0400
Subject: [PATCH 8/9] Refactor vgsplit - reorder _vgsplit_from and _vgsplit_to based on flag.
In-Reply-To: <1250198823-11591-8-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-5-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-6-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-7-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change but there is one bug.  If we open the
destination first, we cannot know the 'fmt'.  So in this case we rely on the
user specifying the value in the --metadatatype variable if the destination
is a new VG.  This should at least be noted in the man page or perhaps a
warning should be printed.  Other options don't seem attractive:
- open vg_from a second time
- defer actual creation until later but just obtain the locks in the right
order

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |   45 ++++++++++++++++++++++++++++-----------------
 1 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 7fe39e9..ef1ab2c 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -314,26 +314,37 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	vg_from = _vgsplit_from(cmd, vg_name_from);
-	if (!vg_from) {
-		if (!lock_vg_from_first)
+	if (lock_vg_from_first) {
+		vg_from = _vgsplit_from(cmd, vg_name_from);
+		if (!vg_from)
+			return ECMD_FAILED;
+		/*
+		 * Set metadata format of original VG.
+		 * NOTE: We must set the format before calling vg_create()
+		 * since vg_create() calls the per-format constructor.
+		 */
+		cmd->fmt = vg_from->fid->fmt;
+
+		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
+		if (!vg_to) {
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			return ECMD_FAILED;
+		}
+	} else {
+		/* FIXME: in this case we don't know the vg_from->fid->fmt */
+		if (!arg_count(cmd, metadatatype_ARG))
+			log_warn("Unable to set format based on "
+				 "source VG format");
+		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
+		if (!vg_to)
+			return ECMD_FAILED;
+		vg_from = _vgsplit_from(cmd, vg_name_from);
+		if (!vg_from) {
 			unlock_and_release_vg(cmd, vg_to, vg_name_to);
-		return ECMD_FAILED;
+			return ECMD_FAILED;
+		}
 	}
 
-	/*
-	 * Set metadata format of original VG.
-	 * NOTE: We must set the format before calling vg_create()
-	 * since vg_create() calls the per-format constructor.
-	 */
-	cmd->fmt = vg_from->fid->fmt;
-
-	vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
-	if (!vg_to) {
-		if (lock_vg_from_first)
-			unlock_and_release_vg(cmd, vg_from, vg_name_from);
-		return ECMD_FAILED;
-	}
 	if (existing_vg) {
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
-- 
1.6.0.6


