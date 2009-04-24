From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 24 Apr 2009 16:19:28 -0400
Subject: [PATCH] enable config command line option for backup (update)
In-Reply-To: <49F20E6E.3000400@redhat.com>
References: <49F20E6E.3000400@redhat.com>
Message-ID: <49F21ED0.5070406@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I fixed memory leak on the previous patch when archive_init()
and backup_init() is called several times.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.



This patch enables to configure options related to backup and archive
by "--config" option in commandline.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/commands/toolcontext.c |    5 +++++
 lib/format_text/archiver.c |   10 ++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

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
Index: LVM2.02.46-20090422/lib/format_text/archiver.c
===================================================================
--- LVM2.02.46-20090422.orig/lib/format_text/archiver.c
+++ LVM2.02.46-20090422/lib/format_text/archiver.c
@@ -40,8 +40,9 @@ int archive_init(struct cmd_context *cmd
 		 unsigned int keep_days, unsigned int keep_min,
 		 int enabled)
 {
-	if (!(cmd->archive_params = dm_pool_zalloc(cmd->libmem,
-						sizeof(*cmd->archive_params)))) {
+	if (!cmd->archive_params &&
+	    !(cmd->archive_params = dm_pool_zalloc(cmd->libmem,
+					sizeof(*cmd->archive_params)))) {
 		log_error("archive_params alloc failed");
 		return 0;
 	}
@@ -154,8 +155,9 @@ int archive_display_file(struct cmd_cont
 int backup_init(struct cmd_context *cmd, const char *dir,
 		int enabled)
 {
-	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
-					       sizeof(*cmd->backup_params)))) {
+	if (!cmd->backup_params &&
+	    !(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
+					sizeof(*cmd->backup_params)))) {
 		log_error("backup_params alloc failed");
 		return 0;
 	}


