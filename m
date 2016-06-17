From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Jun 2016 17:27:43 +0000 (UTC)
Subject: master - vgreduce: fix location of lvmlockd global lock
Message-ID: <20160617172743.011BE61169@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=029f51e1a853297ca7246b75ac80cde9de23a2a4
Commit:        029f51e1a853297ca7246b75ac80cde9de23a2a4
Parent:        899a4ca275543425ca60fe361bc13fbc5c90e741
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 17 12:10:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 17 12:22:58 2016 -0500

vgreduce: fix location of lvmlockd global lock

The lvmlockd global lock was missing the non-repair case,
which caused the new orphan PV created by vgreduce to
not be seen by other hosts.
---
 tools/vgreduce.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 19a0bb0..3176a0e 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -217,6 +217,11 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 	argc--;
 
+	/* Needed to change the set of orphan PVs. */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+	cmd->lockd_gl_disable = 1;
+
 	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -236,13 +241,6 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 
 	vp.force = arg_count(cmd, force_ARG);
 
-	/* Needed to change the set of orphan PVs. */
-	if (!lockd_gl(cmd, "ex", 0)) {
-		ret = ECMD_FAILED;
-		goto_out;
-	}
-	cmd->lockd_gl_disable = 1;
-
 	cmd->handles_missing_pvs = 1;
 
 	init_ignore_suspended_devices(1);


