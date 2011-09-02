From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Sep 2011 01:59:08 -0000
Subject: LVM2/lib commands/toolcontext.c config/config.c
Message-ID: <20110902015908.30814.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-02 01:59:08

Modified files:
	lib/commands   : toolcontext.c 
	lib/config     : config.c 

Log message:
	temp notes on dealing with cascade

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/lib/commands/toolcontext.c	2011/09/02 01:32:09	1.133
+++ LVM2/lib/commands/toolcontext.c	2011/09/02 01:59:07	1.134
@@ -608,6 +608,7 @@
 	struct config_tree_list *cfl;
 	struct dm_config_tree *cft_cmdline = NULL, *cft;
 
+// FIXME No need for this - only one config tree now
 	cft = dm_config_remove_cascaded_tree(cmd->cft);
 	if (cft) {
 		cft_cmdline = cmd->cft;
@@ -1429,6 +1430,7 @@
 	}
 	dev_cache_exit();
 	_destroy_tags(cmd);
+// FIXME Use cmd->cft_cmdline instead here.
 	cft_cmdline = _destroy_tag_configs(cmd);
 
 	cmd->config_valid = 0;
@@ -1441,6 +1443,7 @@
 	/* Temporary duplicate cft pointer holding lvm.conf - replaced later */
 	cft_tmp = cmd->cft;
 	if (cft_cmdline)
+// FIXME Use cmd->cft_cmdline (convert string to cft again?) and merge instead
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cft_tmp);
 
 	/* Uses cmd->cft i.e. cft_cmdline + lvm.conf */
@@ -1454,11 +1457,15 @@
 	if (!_init_tag_configs(cmd))
 		return 0;
 
+// FIXME Will need to use a fresh copy of the lvm.conf cft as the original
+// FIXME got destroyed when cft_cmdline was merged into it
 	/* Merge all the tag config files with lvm.conf, returning a
 	 * fresh cft pointer in place of cft_tmp. */
 	if (!(cmd->cft = _merge_config_files(cmd, cft_tmp)))
 		return 0;
 
+// FIXME Merge instead - but keep a clean copy of cmd->cft at this point
+// FIXME so we can easily 'remove' the effect of cft_cmdline after each cmd
 	/* Finally we can make the proper, fully-merged, cmd->cft */
 	if (cft_cmdline)
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cmd->cft);
@@ -1509,6 +1516,8 @@
 		dm_pool_destroy(cmd->mem);
 	dev_cache_exit();
 	_destroy_tags(cmd);
+
+// FIXME destroy_tag_configs handles this itself again
 	if ((cft_cmdline = _destroy_tag_configs(cmd)))
 		dm_config_destroy(cft_cmdline);
 	if (cmd->libmem)
--- LVM2/lib/config/config.c	2011/09/02 01:32:09	1.105
+++ LVM2/lib/config/config.c	2011/09/02 01:59:07	1.106
@@ -45,6 +45,7 @@
  */
 struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd)
 {
+// FIXME Replace cmd->cft with clean copy of merged lvm*.conf tree
 	struct dm_config_tree *old_cft = cmd->cft;
 	struct dm_config_tree *cft = dm_config_remove_cascaded_tree(cmd->cft);
 
@@ -56,6 +57,8 @@
 	return old_cft;
 }
 
+// FIXME Retain a copy of the string (or tree?) in cmd->cft_cmdline
+// FIXME and merge into cmd->cft
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {


