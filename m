From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 22:18:33 -0000
Subject: LVM2/lib format_text/archiver.c label/label.c
Message-ID: <20090708221833.32518.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 22:18:32

Modified files:
	lib/format_text: archiver.c 
	lib/label      : label.c 

Log message:
	Make exit paths more robust when some init function fails.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/lib/format_text/archiver.c	2009/05/19 09:45:33	1.25
+++ LVM2/lib/format_text/archiver.c	2009/07/08 22:18:32	1.26
@@ -65,6 +65,8 @@
 
 void archive_exit(struct cmd_context *cmd)
 {
+	if (!cmd->archive_params)
+		return;
 	if (cmd->archive_params->dir)
 		dm_free(cmd->archive_params->dir);
 	memset(cmd->archive_params, 0, sizeof(*cmd->archive_params));
@@ -175,6 +177,8 @@
 
 void backup_exit(struct cmd_context *cmd)
 {
+	if (!cmd->backup_params)
+		return;
 	if (cmd->backup_params->dir)
 		dm_free(cmd->backup_params->dir);
 	memset(cmd->backup_params, 0, sizeof(*cmd->backup_params));
--- LVM2/lib/label/label.c	2009/02/20 23:19:28	1.46
+++ LVM2/lib/label/label.c	2009/07/08 22:18:32	1.47
@@ -72,7 +72,7 @@
 	struct dm_list *c, *n;
 	struct labeller_i *li;
 
-	for (c = _labellers.n; c != &_labellers; c = n) {
+	for (c = _labellers.n; c && c != &_labellers; c = n) {
 		n = c->n;
 		li = dm_list_item(c, struct labeller_i);
 		li->l->ops->destroy(li->l);


