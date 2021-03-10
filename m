From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:42 +0000 (GMT)
Subject: main - cov: unused value
Message-ID: <20210310003642.41058385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74936f53f7123c092d2ba6b9b7883db47bf0c61c
Commit:        74936f53f7123c092d2ba6b9b7883db47bf0c61c
Parent:        d95c0e977cb69b04467d650a8be9b0efa2c71688
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 15:51:11 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:29:44 2021 +0100

cov: unused value

---
 daemons/lvmlockd/lvmlockd-core.c | 2 +-
 tools/vgimportdevices.c          | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b271a9aee..094491029 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2682,7 +2682,7 @@ out_rem:
 
 	log_debug("S %s clearing locks", ls->name);
 
-	rv = clear_locks(ls, free_vg, drop_vg);
+	(void) clear_locks(ls, free_vg, drop_vg);
 
 	/*
 	 * Tell any other hosts in the lockspace to leave it
diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index 88435af92..af0e618aa 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -113,7 +113,7 @@ int vgimportdevices(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct vgimportdevices_params vp = { 0 };
 	struct processing_handle *handle;
-	int ret = ECMD_PROCESSED;
+	int ret = ECMD_FAILED;
 
 	if (arg_is_set(cmd, foreign_ARG))
 		cmd->include_foreign_vgs = 1;
@@ -152,7 +152,6 @@ int vgimportdevices(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
-		ret = ECMD_FAILED;
 		goto out;
 	}
 	handle->custom_handle = &vp;


