From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Jan 2016 20:39:16 +0000 (UTC)
Subject: master - lvmlockd: remove noisy log_debug
Message-ID: <20160121203916.5ED5B60F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc388e0c7af967568527dd1bccb0361ca668f09b
Commit:        dc388e0c7af967568527dd1bccb0361ca668f09b
Parent:        55056c2d16a6cb6e0ce5b7179d62d4dc28cd790d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 21 14:37:15 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 21 14:37:15 2016 -0600

lvmlockd: remove noisy log_debug

The debug message appeared even when lvmlockd was not used,
and the lockd operation was simply being skipped.
---
 lib/locking/lvmlockd.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 1af40b7..a33544c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1702,10 +1702,8 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	 * passed back to lockd_vg() for the corresponding unlock.
 	 */
 	if (def_mode && !strcmp(def_mode, "un")) {
-		if (prev_state & LDST_FAIL) {
-			log_debug("VG %s unlock skipped: lockd_state is failed", vg_name);
+		if (prev_state & LDST_FAIL)
 			return 1;
-		}
 
 		mode = "un";
 		goto req;


