From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 14 Dec 2015 20:20:18 +0000 (UTC)
Subject: master - pvscan: Remove duplicate filter wipe.
Message-ID: <20151214202018.666B060C8F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37bd35bc3ddbd4b669c523e2f56aaa68682df2ad
Commit:        37bd35bc3ddbd4b669c523e2f56aaa68682df2ad
Parent:        92e14227074f70eb824a93023a7dbc7cafb0e4f3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 14 20:14:59 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 14 20:14:59 2015 +0000

pvscan: Remove duplicate filter wipe.

Also always clear the internal lvmcache after rescanning, and
reinstate a test for --trustcache so that 'pvs --trustcache'
(for example) avoids rescanning.
---
 tools/pvscan.c  |    4 ----
 tools/toollib.c |    5 ++++-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 460b74d..68a074e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -404,10 +404,6 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "sh", 0))
 		return_ECMD_FAILED;
 
-	if (cmd->full_filter->wipe)
-		cmd->full_filter->wipe(cmd->full_filter);
-
-	lvmcache_destroy(cmd, 1, 0);
 
 	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
diff --git a/tools/toollib.c b/tools/toollib.c
index fb6edad..0b9f505 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3344,7 +3344,10 @@ int process_each_pv(struct cmd_context *cmd,
 	 * it were not done here first.  It's called here first
 	 * so that get_vgnameids() will look at any new devices.
 	 */
-	dev_cache_full_scan(cmd->full_filter);
+	if (!trust_cache()) {
+		dev_cache_full_scan(cmd->full_filter);
+		lvmcache_destroy(cmd, 1, 0);
+	}
 
 	/*
 	 * Need pvid's set on all PVs before processing so that pvid's


