From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:57:29 -0400
Subject: [PATCH 12/13] Refactor vgmerge - combine _vgmerge_to and _vgmerge_from into _vgmerge_vg_read.
In-Reply-To: <1250200650-12896-2-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250200650-12896-1-git-send-email-dwysocha@redhat.com>
	<1250200650-12896-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1250200650-12896-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These functions are identical so should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgmerge.c |   34 ++++++++++------------------------
 1 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 4dbcd61..9e38e6c 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -15,31 +15,17 @@
 
 #include "tools.h"
 
-static struct volume_group *_vgmerge_from(struct cmd_context *cmd,
-					  const char *vg_name_from)
+static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
+					     const char *vg_name)
 {
-	struct volume_group *vg_from;
-	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
-	if (vg_read_error(vg_from)) {
-		vg_release(vg_from);
+	struct volume_group *vg;
+	log_verbose("Checking for volume group \"%s\"", vg_name);
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return NULL;
 	}
-	return vg_from;
-}
-
-static struct volume_group *_vgmerge_to(struct cmd_context *cmd,
-					const char *vg_name_to)
-{
-	struct volume_group *vg_to;
-
-	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
-	if (vg_read_error(vg_to)) {
-		vg_release(vg_to);
-		return NULL;
-	}
-	return vg_to;
+	return vg;
 }
 
 static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
@@ -55,11 +41,11 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		return ECMD_FAILED;
 	}
 
-	vg_to = _vgmerge_to(cmd, vg_name_to);
+	vg_to = _vgmerge_vg_read(cmd, vg_name_to);
 	if (!vg_to)
 		return ECMD_FAILED;
 
-	vg_from = _vgmerge_from(cmd, vg_name_from);
+	vg_from = _vgmerge_vg_read(cmd, vg_name_from);
 	if (!vg_from) {
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
-- 
1.6.0.6


