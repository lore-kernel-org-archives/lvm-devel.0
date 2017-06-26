From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:30:00 -0400
Subject: master - coverity: add some error path for failed allocs
Message-ID: <201706262230.v5QMU09v010439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=664e947726ad3e64b59b2e3d43cd4ea01f7e5d5a
Commit:        664e947726ad3e64b59b2e3d43cd4ea01f7e5d5a
Parent:        72c5598658764e1b0054c0cb40e6a4770c11f660
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:57:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

coverity: add some error path for failed allocs

Coverity reports some unchecked allocations.
---
 daemons/dmfilemapd/dmfilemapd.c |    3 ++-
 tools/lvmcmdline.c              |    5 ++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 43ae970..a1293dc 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -709,7 +709,8 @@ static int _dmfilemapd(struct filemap_monitor *fm)
 	 * The correct program_id is retrieved from the group leader
 	 * following the call to dm_stats_list().
 	 */
-	dms = dm_stats_create(NULL);
+	if (!(dms = dm_stats_create(NULL)))
+		goto_bad;
 
 	if (!dm_stats_bind_from_fd(dms, fm->fd)) {
 		log_error("Could not bind dm_stats handle to file descriptor "
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0aca37a..964e295 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2703,7 +2703,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
-	cmd->name = dm_pool_strdup(cmd->mem, dm_basename(argv[0]));
+	if (!(cmd->name = dm_pool_strdup(cmd->mem, dm_basename(argv[0])))) {
+		log_error("Failed to strdup command basename.");
+		return ECMD_FAILED;
+	}
 
 	configure_command_option_values(cmd->name);
 


