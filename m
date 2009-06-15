From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Jun 2009 11:56:40 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20090615115640.9629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-15 11:56:37

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Fix memory leaks in toolcontext error path.
	
	E.g.
	# vgscan
	Parse error at byte 2360 (line 54): expected a value
	Failed to load config file /etc/lvm/lvm.conf
	You have a memory leak (not released memory pool):
	[0x818c788] library (12 bytes)
	
	...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1147&r2=1.1148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2009/06/12 08:34:15	1.1147
+++ LVM2/WHATS_NEW	2009/06/15 11:56:31	1.1148
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix memory leaks in toolcontext error path.
   Re-instate partial activation support in clustered mode. (2.02.40)
   Allow metadata correction even when PVs are missing.
   Use 'lvm lvresize' instead of 'lvresize' in fsadm.
--- LVM2/lib/commands/toolcontext.c	2009/04/02 20:46:11	1.74
+++ LVM2/lib/commands/toolcontext.c	2009/06/15 11:56:36	1.75
@@ -516,15 +516,15 @@
 {
 	struct config_tree_list *cfl;
 
+	dm_list_iterate_items(cfl, &cmd->config_files) {
+		destroy_config_tree(cfl->cft);
+	}
+
 	if (cmd->cft && cmd->cft->root) {
 		destroy_config_tree(cmd->cft);
 		cmd->cft = NULL;
 	}
 
-	dm_list_iterate_items(cfl, &cmd->config_files) {
-		destroy_config_tree(cfl->cft);
-	}
-
 	dm_list_init(&cmd->config_files);
 }
 
@@ -1110,6 +1110,14 @@
 	return cmd;
 
       error:
+	_destroy_tag_configs(cmd);
+	dev_cache_exit();
+	if (cmd->filter)
+		cmd->filter->destroy(cmd->filter);
+	if (cmd->mem)
+		dm_pool_destroy(cmd->mem);
+	if (cmd->libmem)
+		dm_pool_destroy(cmd->libmem);
 	dm_free(cmd);
 	return NULL;
 }


