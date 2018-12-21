From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:13 -0500
Subject: master - cov: ensure lock_type is not NULL
Message-ID: <201812212047.wBLKlD0d021494@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8db2527c6edec81d3b90d30384e32784ab2ec687
Commit:        8db2527c6edec81d3b90d30384e32784ab2ec687
Parent:        e2c017fdace76f0c03f43e3e435ae8a72d6bb15f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:04:35 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

cov: ensure lock_type is not NULL

---
 tools/vgchange.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 0f9241c..bbdf2e4 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -818,7 +818,7 @@ static int _vgchange_locktype(struct cmd_context *cmd, struct volume_group *vg)
 	int lv_lock_count = 0;
 
 	/* Special recovery case. */
-	if (lockopt && !strcmp(lock_type, "none") && !strcmp(lockopt, "force")) {
+	if (lock_type && lockopt && !strcmp(lock_type, "none") && !strcmp(lockopt, "force")) {
 		vg->status &= ~CLUSTERED;
 		vg->lock_type = "none";
 		vg->lock_args = NULL;
@@ -867,7 +867,7 @@ static int _vgchange_locktype(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	/* clvm to none */
-	if (!strcmp(vg->lock_type, "clvm") && !strcmp(lock_type, "none")) {
+	if (lock_type && !strcmp(vg->lock_type, "clvm") && !strcmp(lock_type, "none")) {
 		vg->status &= ~CLUSTERED;
 		vg->lock_type = "none";
 		return 1;
@@ -963,7 +963,7 @@ static int _vgchange_locktype(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	/* ... to none */
-	if (!strcmp(lock_type, "none")) {
+	if (lock_type && !strcmp(lock_type, "none")) {
 		vg->lock_type = NULL;
 		vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
 		return 1;


