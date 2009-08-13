From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:57:27 -0400
Subject: [PATCH 10/13] Refactor vgmerge - introduce lock_vg_from_first flag.
In-Reply-To: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1250200650-12896-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgmerge.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 37f6bd7..39032fb 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -21,6 +21,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	struct volume_group *vg_to, *vg_from;
 	struct lv_list *lvl1, *lvl2;
 	int r = ECMD_FAILED;
+	int lock_vg_from_first = 0;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
@@ -116,8 +117,13 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		  vg_from->name, vg_to->name);
 	r = ECMD_PROCESSED;
 bad:
-	unlock_and_release_vg(cmd, vg_from, vg_name_from);
-	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	if (lock_vg_from_first) {
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	} else {
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	}
 	return r;
 }
 
-- 
1.6.0.6


