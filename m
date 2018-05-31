From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:49 -0400
Subject: master - pvremove: skip lvmlockd locks for forced clearing
Message-ID: <201805311414.w4VEEnCH031237@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3759a1f62bf314fbe2f25b2365c1aebca8071e31
Commit:        3759a1f62bf314fbe2f25b2365c1aebca8071e31
Parent:        5c5e449dc5f955481f9409ff0e7ed39cf7b2e87d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 15:57:17 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

pvremove: skip lvmlockd locks for forced clearing

pvremove -ff to force clear a PV shouldn't care if
lvmlockd locks fail.
---
 tools/pvremove.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/tools/pvremove.c b/tools/pvremove.c
index 28c7b83..06a7e73 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -39,10 +39,19 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 	 * (disable afterward to prevent process_each_pv from doing
 	 * a shared global lock since it's already acquired it ex.)
 	 */
-	if (!lockd_gl(cmd, "ex", 0))
-		return_ECMD_FAILED;
+	if (!lockd_gl(cmd, "ex", 0)) {
+		/* Let pvremove -ff skip locks */
+		if (pp.force == DONT_PROMPT_OVERRIDE)
+			log_warn("WARNING: skipping global lock in lvmlockd for force.");
+		else
+			return_ECMD_FAILED;
+	}
 	cmd->lockd_gl_disable = 1;
 
+	/* When forcibly clearing a PV we don't care about a VG lock. */
+	if (pp.force == DONT_PROMPT_OVERRIDE)
+		cmd->lockd_vg_disable = 1;
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;


