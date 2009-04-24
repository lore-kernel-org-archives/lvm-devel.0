From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 24 Apr 2009 15:09:34 -0400
Subject: [PATCH] enable config command line option for backup
Message-ID: <49F20E6E.3000400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch enables to configure options related to backup and archive
by "--config" command line option.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/commands/toolcontext.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: LVM2.02.46-20090422/lib/commands/toolcontext.c
===================================================================
--- LVM2.02.46-20090422.orig/lib/commands/toolcontext.c
+++ LVM2.02.46-20090422/lib/commands/toolcontext.c
@@ -1160,6 +1160,8 @@ int refresh_toolcontext(struct cmd_conte
 	 */
 
 	activation_release();
+	archive_exit(cmd);
+	backup_exit(cmd);
 	lvmcache_destroy(cmd, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
@@ -1208,6 +1210,9 @@ int refresh_toolcontext(struct cmd_conte
 	if (!_init_segtypes(cmd))
 		return 0;
 
+	if (!_init_backup(cmd))
+		return 0;
+
 	/*
 	 * If we are a long-lived process, write out the updated persistent
 	 * device cache for the benefit of short-lived processes.


