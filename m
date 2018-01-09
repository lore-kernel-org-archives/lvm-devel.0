From: David Teigland <teigland@sourceware.org>
Date: Tue, 9 Jan 2018 12:46:33 -0500
Subject: master - lvmlockd: print warning when skipping locking
Message-ID: <201801091746.w09HkXd6005774@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51340888aab5e1b8630c7d8083e621ca0f4e4264
Commit:        51340888aab5e1b8630c7d8083e621ca0f4e4264
Parent:        46cedb105bb7fdba0107794ca5801c2a0e8fd524
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 9 11:46:00 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 9 11:46:00 2018 -0600

lvmlockd: print warning when skipping locking

---
 tools/lvmcmdline.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 791e272..6be4bcd 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2684,12 +2684,18 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 
 	if (use_lvmlockd && arg_is_set(cmd, lockopt_ARG)) {
 		const char *opts = arg_str_value(cmd, lockopt_ARG, "");
-		if (strstr(opts, "skiplv"))
+		if (strstr(opts, "skiplv")) {
+			log_warn("WARNING: skipping LV lock in lvmlockd.");
 			cmd->lockd_lv_disable = 1;
-		if (strstr(opts, "skipvg"))
+		}
+		if (strstr(opts, "skipvg")) {
+			log_warn("WARNING: skipping VG lock in lvmlockd.");
 			cmd->lockd_vg_disable = 1;
-		if (strstr(opts, "skipgl"))
+		}
+		if (strstr(opts, "skipgl")) {
+			log_warn("WARNING: skipping global lock in lvmlockd.");
 			cmd->lockd_gl_disable = 1;
+		}
 	}
 
 	if (use_lvmlockd && locking_is_clustered()) {


