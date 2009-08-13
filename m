From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:26:56 -0400
Subject: [PATCH 2/9] Refactor vgsplit to move existing_vg logic in a separate 'if' statement.
In-Reply-To: <1250198823-11591-2-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This will aid in future refactorings and allow for us to reorder the source
and destination vg based on alphabetical names.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 35c425a..fd4099f 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -290,6 +290,11 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 			goto bad2;
 		}
 
+	} else if (vg_read_error(vg_to) == SUCCESS) {
+		existing_vg = 0;
+	}
+
+	if (existing_vg) {
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
@@ -297,9 +302,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
-	} else if (vg_read_error(vg_to) == SUCCESS) {
-		existing_vg = 0;
-
+	} else {
 		vp_def.vg_name = NULL;
 		vp_def.extent_size = vg_from->extent_size;
 		vp_def.max_pv = vg_from->max_pv;
-- 
1.6.0.6


