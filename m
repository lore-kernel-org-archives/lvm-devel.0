From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Jul 2008 09:19:54 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20080711091954.8912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-07-11 09:19:54

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Fix gcc warnings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/lib/format_text/import_vsn1.c	2008/07/10 11:30:57	1.51
+++ LVM2/lib/format_text/import_vsn1.c	2008/07/11 09:19:54	1.52
@@ -125,7 +125,7 @@
 	return 1;
 }
 
-static int _read_flag_config(struct config_node *n, int *status, int type)
+static int _read_flag_config(struct config_node *n, uint32_t *status, int type)
 {
 	struct config_node *cn;
 	*status = 0;
@@ -140,7 +140,7 @@
 		return 0;
 	}
 
-	if (cn = find_config_node(n, "flags")) {
+	if ((cn = find_config_node(n, "flags"))) {
 		if (!(read_flags(status, type, cn->v))) {
 			log_error("Could not read flags.");
 			return 0;
@@ -836,7 +836,7 @@
 				struct config_tree *cft, struct id *vgid,
 				uint32_t *vgstatus, char **creation_host)
 {
-	struct config_node *vgn, *cn;
+	struct config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
 	char *vgname;
 	int old_suppress;


