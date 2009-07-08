From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 18:12:08 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20090708181208.27957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 18:12:08

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Make destroy_toolcontext() better able to handle NULL pointers.
	
	Part of twoerner's log_error() patches.
	
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/lib/commands/toolcontext.c	2009/07/08 12:36:01	1.77
+++ LVM2/lib/commands/toolcontext.c	2009/07/08 18:12:08	1.78
@@ -1302,12 +1302,15 @@
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(&cmd->formats);
-	cmd->filter->destroy(cmd->filter);
-	dm_pool_destroy(cmd->mem);
+	if (cmd->filter)
+		cmd->filter->destroy(cmd->filter);
+	if (cmd->mem)
+		dm_pool_destroy(cmd->mem);
 	dev_cache_exit();
 	_destroy_tags(cmd);
 	_destroy_tag_configs(cmd);
-	dm_pool_destroy(cmd->libmem);
+	if (cmd->libmem)
+		dm_pool_destroy(cmd->libmem);
 	dm_free(cmd);
 
 	release_log_memory();


