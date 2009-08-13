From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:26:59 -0400
Subject: [PATCH 5/9] Refactor vgsplit - create _vgsplit_to function which creates or opens dest vg.
In-Reply-To: <1250198823-11591-5-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the creating/opening of the destination vg into its own function so later
we can reorder the source / destination vg opening based on the alphabetical
lock order rule.

Should be no functional change but code is a bit tricky.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |   79 +++++++++++++++++++++++++++++++++---------------------
 1 files changed, 48 insertions(+), 31 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 1a9e45e..508d547 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -198,6 +198,52 @@ static int _move_mirrors(struct volume_group *vg_from,
 }
 
 /*
+ * Create or open the destination of the vgsplit operation.
+ * Returns
+ * - non-NULL: VG handle w/VG lock held
+ * - NULL: no VG lock held
+ */
+static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
+					const char *vg_name_to,
+					int *existing_vg)
+{
+	struct volume_group *vg_to = NULL;
+
+	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
+	/*
+	 * First try to create a new VG.  If we cannot create it,
+	 * and we get FAILED_EXIST (we will not be holding a lock),
+	 * a VG must already exist with this name.  We then try to
+	 * read the existing VG - the vgsplit will be into an existing VG.
+	 *
+	 * Otherwise, if the lock was successful, it must be the case that
+	 * we obtained a WRITE lock and could not find the vgname in the
+	 * system.  Thus, the split will be into a new VG.
+	 */
+	vg_to = vg_create(cmd, vg_name_to);
+	if (vg_read_error(vg_to) == FAILED_LOCKING) {
+		log_error("Can't get lock for %s", vg_name_to);
+		vg_release(vg_to);
+		return NULL;
+	}
+	if (vg_read_error(vg_to) == FAILED_EXIST) {
+		*existing_vg = 1;
+		vg_release(vg_to);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+
+		if (vg_read_error(vg_to)) {
+			vg_release(vg_to);
+			stack;
+			return NULL;
+		}
+
+	} else if (vg_read_error(vg_to) == SUCCESS) {
+		*existing_vg = 0;
+	}
+	return vg_to;
+}
+
+/*
  * Has the user given an option related to a new vg as the split destination?
  */
 static int new_vg_option_specified(struct cmd_context *cmd)
@@ -262,40 +308,11 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	cmd->fmt = vg_from->fid->fmt;
 
-	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	/*
-	 * First try to create a new VG.  If we cannot create it,
-	 * and we get FAILED_EXIST (we will not be holding a lock),
-	 * a VG must already exist with this name.  We then try to
-	 * read the existing VG - the vgsplit will be into an existing VG.
-	 *
-	 * Otherwise, if the lock was successful, it must be the case that
-	 * we obtained a WRITE lock and could not find the vgname in the
-	 * system.  Thus, the split will be into a new VG.
-	 */
-	vg_to = vg_create(cmd, vg_name_to);
-	if (vg_read_error(vg_to) == FAILED_LOCKING) {
-		log_error("Can't get lock for %s", vg_name_to);
-		vg_release(vg_to);
+	vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
+	if (!vg_to) {
 		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
-	if (vg_read_error(vg_to) == FAILED_EXIST) {
-		existing_vg = 1;
-		vg_release(vg_to);
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
-
-		if (vg_read_error(vg_to)) {
-			vg_release(vg_to);
-			stack;
-			unlock_and_release_vg(cmd, vg_from, vg_name_from);
-			return ECMD_FAILED;
-		}
-
-	} else if (vg_read_error(vg_to) == SUCCESS) {
-		existing_vg = 0;
-	}
-
 	if (existing_vg) {
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
-- 
1.6.0.6


