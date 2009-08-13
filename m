From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:57:30 -0400
Subject: [PATCH 13/13] Change vgmerge behavior to open/lock first vg based on alphabetical ordering.
In-Reply-To: <1250200650-12896-3-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250200650-12896-1-git-send-email-dwysocha@redhat.com>
	<1250200650-12896-2-git-send-email-dwysocha@redhat.com>
	<1250200650-12896-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1250200650-12896-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This enforces our alphabetical lock ordering rules for vgmerge.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgmerge.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 9e38e6c..e147d27 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -41,14 +41,28 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		return ECMD_FAILED;
 	}
 
-	vg_to = _vgmerge_vg_read(cmd, vg_name_to);
-	if (!vg_to)
-		return ECMD_FAILED;
+	if (strcmp(vg_name_to, vg_name_from) > 0)
+		lock_vg_from_first = 1;
 
-	vg_from = _vgmerge_vg_read(cmd, vg_name_from);
-	if (!vg_from) {
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
-		return ECMD_FAILED;
+	if (lock_vg_from_first) {
+		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
+		if (!vg_from)
+			return ECMD_FAILED;
+		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
+		if (!vg_to) {
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			return ECMD_FAILED;
+		}
+	} else {
+		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
+		if (!vg_to)
+			return ECMD_FAILED;
+
+		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
+		if (!vg_from) {
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
+			return ECMD_FAILED;
+		}
 	}
 
 	if (!vgs_are_compatible(cmd, vg_from, vg_to))
-- 
1.6.0.6


