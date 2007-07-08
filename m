From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2007 22:51:22 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20070708225122.22491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-08 22:51:21

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Fix dumpconfig to use log_print instead of stdout directly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.647&r2=1.648
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2007/07/03 13:10:14	1.647
+++ LVM2/WHATS_NEW	2007/07/08 22:51:20	1.648
@@ -1,10 +1,11 @@
 Version 2.02.27 - 
 ================================
+  Fix dumpconfig to use log_print instead of stdout directly.
   Remove unused parameter 'fid' from _add_pv_to_vg.
-  Add kernel and device-mapper targets versions report to lvmdump.
-  Don't use index and rindex functions marked by SUSv3 as legacy.
-  Fix vgsplit if splitting all PVs from VG.
-  Fix lvmdiskscan volume reporting when run in the lvm shell
+  Add kernel and device-mapper targets versions to lvmdump.
+  Replace BSD (r)index with C89 str(r)chr.
+  Handle vgsplit of an entire VG as a vgrename.
+  Reinitialise internal lvmdiskscan variables when called repeatedly.
   Fix missing lvm_shell symbol in lvm2cmd library. (2.02.23)
   Add vg_status function and clean up vg->status in tools directory.
   Add --ignoremonitoring to disable all dmeventd interaction.
--- LVM2/lib/config/config.c	2007/06/13 15:11:19	1.59
+++ LVM2/lib/config/config.c	2007/07/08 22:51:20	1.60
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -66,6 +66,11 @@
 	struct device *dev;
 };
 
+struct output_line {
+	FILE *fp;
+	struct dm_pool *mem;
+};
+
 static void _get_token(struct parser *p, int tok_prev);
 static void _eat_space(struct parser *p);
 static struct config_node *_file(struct parser *p);
@@ -345,33 +350,87 @@
 	return 1;
 }
 
-static void _write_value(FILE *fp, struct config_value *v)
+static int _line_start(struct output_line *outline)
+{
+	if (!dm_pool_begin_object(outline->mem, 128)) {
+		log_error("dm_pool_begin_object failed for config line");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _line_append(struct output_line *outline, const char *fmt, ...)
+{
+	char buf[4096];
+	va_list ap;
+	int n;
+
+	va_start(ap, fmt);
+	n = vsnprintf(&buf[0], 4095, fmt, ap);
+	if (n < 0 || n > 4095) {
+		log_error("vsnprintf failed for config line");
+		return 0;
+	}
+	va_end(ap);
+
+	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
+		log_error("dm_pool_grew_object failed for config line");
+		return 0;
+	}
+
+	return 1;
+}
+
+#define line_append(args...) do {if (!_line_append(outline, args)) {return_0;}} while (0)
+
+static int _line_end(struct output_line *outline)
+{
+	const char *line;
+
+	if (!dm_pool_grow_object(outline->mem, "\0", 1)) {
+		log_error("dm_pool_grow_object failed for config line");
+		return 0;
+	}
+
+	line = dm_pool_end_object(outline->mem);
+	if (!outline->fp)
+		log_print("%s", line);
+	else
+		fprintf(outline->fp, "%s\n", line);
+
+	return 1;
+}
+
+static int _write_value(struct output_line *outline, struct config_value *v)
 {
 	switch (v->type) {
 	case CFG_STRING:
-		fprintf(fp, "\"%s\"", v->v.str);
+		line_append("\"%s\"", v->v.str);
 		break;
 
 	case CFG_FLOAT:
-		fprintf(fp, "%f", v->v.r);
+		line_append("%f", v->v.r);
 		break;
 
 	case CFG_INT:
-		fprintf(fp, "%" PRId64, v->v.i);
+		line_append("%" PRId64, v->v.i);
 		break;
 
 	case CFG_EMPTY_ARRAY:
-		fprintf(fp, "[]");
+		line_append("[]");
 		break;
 
 	default:
 		log_error("_write_value: Unknown value type: %d", v->type);
 
 	}
+
+	return 1;
 }
 
-static int _write_config(struct config_node *n, int only_one, FILE *fp,
-			 int level)
+static int _write_config(struct config_node *n, int only_one,
+			 struct output_line *outline, int level)
 {
 	char space[MAX_INDENT + 1];
 	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
@@ -385,29 +444,38 @@
 	space[i] = '\0';
 
 	do {
-		fprintf(fp, "%s%s", space, n->key);
+		if (!_line_start(outline))
+			return_0;
+		line_append("%s%s", space, n->key);
 		if (!n->v) {
 			/* it's a sub section */
-			fprintf(fp, " {\n");
-			_write_config(n->child, 0, fp, level + 1);
-			fprintf(fp, "%s}", space);
+			line_append(" {");
+			if (!_line_end(outline))
+				return_0;
+			if (!_line_start(outline))
+				return_0;
+			_write_config(n->child, 0, outline, level + 1);
+			line_append("%s}", space);
 		} else {
 			/* it's a value */
 			struct config_value *v = n->v;
-			fprintf(fp, "=");
+			line_append("=");
 			if (v->next) {
-				fprintf(fp, "[");
+				line_append("[");
 				while (v) {
-					_write_value(fp, v);
+					if (!_write_value(outline, v))
+						return_0;
 					v = v->next;
 					if (v)
-						fprintf(fp, ", ");
+						line_append(", ");
 				}
-				fprintf(fp, "]");
+				line_append("]");
 			} else
-				_write_value(fp, v);
+				if (!_write_value(outline, v))
+					return_0;
 		}
-		fprintf(fp, "\n");
+		if (!_line_end(outline))
+			return_0;
 		n = n->sib;
 	} while (n && !only_one);
 	/* FIXME: add error checking */
@@ -419,25 +487,27 @@
 {
 	struct config_node *cn;
 	int r = 1;
-	FILE *fp;
+	struct output_line outline;
+	outline.fp = NULL;
 
-	if (!file) {
-		fp = stdout;
+	if (!file)
 		file = "stdout";
-	} else if (!(fp = fopen(file, "w"))) {
+	else if (!(outline.fp = fopen(file, "w"))) {
 		log_sys_error("open", file);
 		return 0;
 	}
 
+	outline.mem = dm_pool_create("config_line", 1024);
+
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
-		if (!_write_config(cft->root, 0, fp, 0)) {
+		if (!_write_config(cft->root, 0, &outline, 0)) {
 			log_error("Failure while writing to %s", file);
 			r = 0;
 		}
 	} else while (argc--) {
 		if ((cn = find_config_node(cft->root, *argv))) {
-			if (!_write_config(cn, 1, fp, 0)) {
+			if (!_write_config(cn, 1, &outline, 0)) {
 				log_error("Failure while writing to %s", file);
 				r = 0;
 			}
@@ -448,11 +518,12 @@
 		argv++;
 	}
 
-	if ((fp != stdout) && fclose(fp)) {
+	if (outline.fp && fclose(outline.fp)) {
 		log_sys_error("fclose", file);
 		r = 0;
 	}
 
+	dm_pool_destroy(outline.mem);
 	return r;
 }
 
@@ -918,26 +989,26 @@
 }
 
 struct config_node *find_config_tree_node(struct cmd_context *cmd,
-                                          const char *path)
+					  const char *path)
 {
 	return _find_first_config_node(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path);
 }
 
 const char *find_config_tree_str(struct cmd_context *cmd,
-                                 const char *path, const char *fail)
+				 const char *path, const char *fail)
 {
 	return _find_config_str(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
 }
 
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
-                         int fail)
+			 int fail)
 {
 	/* FIXME Add log_error message on overflow */
 	return (int) _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, (int64_t) fail);
 }
 
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
-                             float fail)
+			     float fail)
 {
 	return _find_config_float(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
 }


