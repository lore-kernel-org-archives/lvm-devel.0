From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:27:00 -0400
Subject: [PATCH 6/9] Refactor vgsplit - create _vgsplit_from function to open source vg.
In-Reply-To: <1250198823-11591-6-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-5-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change and allows future reorder of source and dest
vgs.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 508d547..bfcd7f5 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -244,6 +244,27 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
 }
 
 /*
+ * Open the source of the vgsplit operation.
+ * Returns
+ * - non-NULL: VG handle w/VG lock held
+ * - NULL: no VG lock held
+ */
+static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
+					  const char *vg_name_from)
+{
+	struct volume_group *vg_from;
+
+	log_verbose("Checking for volume group \"%s\"", vg_name_from);
+
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
+	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
+		return NULL;
+	}
+	return vg_from;
+}
+
+/*
  * Has the user given an option related to a new vg as the split destination?
  */
 static int new_vg_option_specified(struct cmd_context *cmd)
@@ -293,13 +314,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
-	if (vg_read_error(vg_from)) {
-		vg_release(vg_from);
+	vg_from = _vgsplit_from(cmd, vg_name_from);
+	if (!vg_from)
 		return ECMD_FAILED;
-	}
 
 	/*
 	 * Set metadata format of original VG.
-- 
1.6.0.6


