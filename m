From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 22 Oct 2009 10:38:08 -0000
Subject: LVM2/lib config/config.c config/config.h unkno ...
Message-ID: <20091022103808.13165.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-10-22 10:38:07

Modified files:
	lib/config     : config.c config.h 
	lib/unknown    : unknown.c 

Log message:
	Fix the "const discarded" warnings introduced in the unknown segment patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/config/config.c	2009/10/16 17:41:51	1.76
+++ LVM2/lib/config/config.c	2009/10/22 10:38:07	1.77
@@ -451,7 +451,7 @@
 	return 1;
 }
 
-static int _write_config(struct config_node *n, int only_one,
+static int _write_config(const struct config_node *n, int only_one,
 			 struct output_line *outline, int level)
 {
 	char space[MAX_INDENT + 1];
@@ -504,7 +504,7 @@
 	return 1;
 }
 
-int write_config_node(struct config_node *cn, putline_fn putline, void *baton)
+int write_config_node(const struct config_node *cn, putline_fn putline, void *baton)
 {
 	struct output_line outline;
 	outline.fp = NULL;
--- LVM2/lib/config/config.h	2009/10/16 17:41:51	1.29
+++ LVM2/lib/config/config.h	2009/10/22 10:38:07	1.30
@@ -71,7 +71,7 @@
 		      int argc, char **argv);
 
 typedef int (*putline_fn)(const char *line, void *baton);
-int write_config_node(struct config_node *cn, putline_fn putline, void *baton);
+int write_config_node(const struct config_node *cn, putline_fn putline, void *baton);
 
 time_t config_file_timestamp(struct config_tree *cft);
 int config_file_changed(struct config_tree *cft);
--- LVM2/lib/unknown/unknown.c	2009/10/16 17:41:52	1.1
+++ LVM2/lib/unknown/unknown.c	2009/10/22 10:38:07	1.2
@@ -35,7 +35,8 @@
 static int _unknown_text_import(struct lv_segment *seg, const struct config_node *sn,
 				struct dm_hash_table *pv_hash)
 {
-	struct config_node *new, *last = NULL, *current, *head = NULL;
+	struct config_node *new, *last = NULL, *head = NULL;
+	const struct config_node *current;
 	log_verbose("importing unknown segment");
 	for (current = sn; current != NULL; current = current->sib) {
 		if (!strcmp(current->key, "type") || !strcmp(current->key, "start_extent") ||


