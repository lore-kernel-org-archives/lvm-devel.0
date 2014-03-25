From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:49 +0000 (UTC)
Subject: master - debug: add proper backtrace debug
Message-ID: <20140325102349.7F86260F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13258d6e96a43fa88b41e21befd31836f21b59dd
Commit:        13258d6e96a43fa88b41e21befd31836f21b59dd
Parent:        89575d68957dacdcad7d106e3ffd71ff96d3144f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 20:31:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:59 2014 +0100

debug: add proper backtrace debug

When failure happens inside refresh, print proper debug backtrace.
---
 lib/commands/toolcontext.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0c59ea0..c76f281 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1619,7 +1619,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	cmd->lib_dir = NULL;
 
 	if (!_init_lvm_conf(cmd))
-		return 0;
+		return_0;
 
 	/* Temporary duplicate cft pointer holding lvm.conf - replaced later */
 	cft_tmp = cmd->cft;
@@ -1631,45 +1631,45 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	/* Init tags from lvm.conf. */
 	if (!_init_tags(cmd, cft_tmp))
-		return 0;
+		return_0;
 
 	/* Doesn't change cmd->cft */
 	if (!_init_tag_configs(cmd))
-		return 0;
+		return_0;
 
 	/* Merge all the tag config files with lvm.conf, returning a
 	 * fresh cft pointer in place of cft_tmp. */
 	if (!(cmd->cft = _merge_config_files(cmd, cft_tmp)))
-		return 0;
+		return_0;
 
 	/* Finally we can make the proper, fully-merged, cmd->cft */
 	if (cft_cmdline)
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cmd->cft);
 
 	if (!_process_config(cmd))
-		return 0;
+		return_0;
 
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
 						find_config_tree_node(cmd, devices_types_CFG, NULL))))
-		return 0;
+		return_0;
 
 	if (!_init_dev_cache(cmd))
-		return 0;
+		return_0;
 
 	if (!_init_filters(cmd, 0))
-		return 0;
+		return_0;
 
 	if (!_init_formats(cmd))
-		return 0;
+		return_0;
 
 	if (!init_lvmcache_orphans(cmd))
-		return 0;
+		return_0;
 
 	if (!_init_segtypes(cmd))
-		return 0;
+		return_0;
 
 	if (!_init_backup(cmd))
-		return 0;
+		return_0;
 
 	cmd->config_initialized = 1;
 


