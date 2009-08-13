From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:57:28 -0400
Subject: [PATCH 11/13] Refactor vgmerge - create _vgmerge_from and _vgmerge_to.
In-Reply-To: <1250200650-12896-1-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250200650-12896-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1250200650-12896-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These functions are really identical but for clarity I made them separate
functions in this patch.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgmerge.c |   40 +++++++++++++++++++++++++++++++---------
 1 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 39032fb..4dbcd61 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -15,6 +15,33 @@
 
 #include "tools.h"
 
+static struct volume_group *_vgmerge_from(struct cmd_context *cmd,
+					  const char *vg_name_from)
+{
+	struct volume_group *vg_from;
+	log_verbose("Checking for volume group \"%s\"", vg_name_from);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
+	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
+		return NULL;
+	}
+	return vg_from;
+}
+
+static struct volume_group *_vgmerge_to(struct cmd_context *cmd,
+					const char *vg_name_to)
+{
+	struct volume_group *vg_to;
+
+	log_verbose("Checking for volume group \"%s\"", vg_name_to);
+	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+	if (vg_read_error(vg_to)) {
+		vg_release(vg_to);
+		return NULL;
+	}
+	return vg_to;
+}
+
 static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 			   const char *vg_name_from)
 {
@@ -28,17 +55,12 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		return ECMD_FAILED;
 	}
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
-	if (vg_read_error(vg_to)) {
-		vg_release(vg_to);
+	vg_to = _vgmerge_to(cmd, vg_name_to);
+	if (!vg_to)
 		return ECMD_FAILED;
-	}
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
-	if (vg_read_error(vg_from)) {
-		vg_release(vg_from);
+	vg_from = _vgmerge_from(cmd, vg_name_from);
+	if (!vg_from) {
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
-- 
1.6.0.6


