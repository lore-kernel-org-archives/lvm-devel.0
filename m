From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:24 +0200
Subject: [PATCH 10/16] lvresize: Specify --resize-fs-only when going to use fsadm resize
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-11-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When lvresize is calling fsadm to resize the file system, originally
it was the default action. However now fsadm support much more
features and it is doing the lvresize by itself. Luckily there is
still a way to tell fsadm to resize only the file system ane leave
the rest up to the lvresize - provide "--resize-fs-only" argument.

This commit adds "--resize-fs-only" argument when we are going to
use fsadm to resize the fs from within the lvresize.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 tools/lvresize.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index ccd6c6e..959c953 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -128,7 +128,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 
 enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
 #define FSADM_CMD "fsadm"
-#define FSADM_CMD_MAX_ARGS 6
+#define FSADM_CMD_MAX_ARGS 7
 #define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
 
 /*
@@ -157,7 +157,15 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	if (arg_count(cmd, force_ARG))
 		argv[i++] = "--force";
 
-	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
+	switch (fcmd) {
+		case FSADM_CMD_RESIZE:
+			argv[i++] = "--resize-fs-only";
+			argv[i++] = "resize";
+			break;
+		case FSADM_CMD_CHECK:
+			argv[i++] = "check";
+			break;
+	}
 
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
 			lp->lv_name) < 0) {
-- 
1.7.4.4


