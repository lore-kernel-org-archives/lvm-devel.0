From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:41 -0400
Subject: master - coverity: ensure lock_type is not NULL
Message-ID: <201803172234.w2HMYfYS011168@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f331eb1c0d060529a3b5e6517c8ac423e21796d3
Commit:        f331eb1c0d060529a3b5e6517c8ac423e21796d3
Parent:        fd6661dfcf7568d32a127e63b0d6c95c010688fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:16:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: ensure lock_type is not NULL

---
 tools/vgchange.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 6d739fe..7cfaab6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -955,7 +955,7 @@ static int _vgchange_locktype(struct cmd_context *cmd, struct volume_group *vg)
 			vg->lock_type = "none";
 	}
 
-	if (!strcmp(vg->lock_type, lock_type)) {
+	if (lock_type && !strcmp(vg->lock_type, lock_type)) {
 		log_warn("New lock type %s matches the current lock type %s.",
 			 lock_type, vg->lock_type);
 		return 1;
@@ -1180,7 +1180,7 @@ int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * just return success when they see the disable flag set.
 	 */
 	if (lockopt && !strcmp(lockopt, "force")) {
-		if (strcmp(lock_type, "none")) {
+		if (lock_type && strcmp(lock_type, "none")) {
 			log_error("Lock type can only be forced to \"none\" for recovery.");
 			return 0;
 		}


