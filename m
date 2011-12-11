From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Dec 2011 23:18:21 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-config.c ...
Message-ID: <20111211231821.14478.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-11 23:18:20

Modified files:
	libdm          : libdevmapper.h libdm-config.c 
	lib/config     : config.c config.h 
	tools          : dumpconfig.c 

Log message:
	Move dm_config_write out of libdm, back to lib/config, as config_write.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/libdm/libdevmapper.h	2011/11/12 22:44:10	1.169
+++ LVM2/libdm/libdevmapper.h	2011/12/11 23:18:20	1.170
@@ -1346,9 +1346,6 @@
 
 void dm_config_destroy(struct dm_config_tree *cft);
 
-int dm_config_write(struct dm_config_tree *cft, const char *file,
-		    int argc, char **argv);
-
 typedef int (*dm_putline_fn)(const char *line, void *baton);
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
 
--- LVM2/libdm/libdm-config.c	2011/12/11 15:18:32	1.16
+++ LVM2/libdm/libdm-config.c	2011/12/11 23:18:20	1.17
@@ -62,7 +62,6 @@
 };
 
 struct output_line {
-	FILE *fp;
 	struct dm_pool *mem;
 	dm_putline_fn putline;
 	void *putline_baton;
@@ -356,14 +355,11 @@
 	}
 
 	line = dm_pool_end_object(outline->mem);
-	if (outline->putline)
-		outline->putline(line, outline->putline_baton);
-	else {
-		if (!outline->fp)
-			log_print("%s", line);
-		else
-			fprintf(outline->fp, "%s\n", line);
-	}
+
+	if (!outline->putline)
+		return 0;
+
+	outline->putline(line, outline->putline_baton);
 
 	return 1;
 }
@@ -458,7 +454,6 @@
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
 {
 	struct output_line outline;
-	outline.fp = NULL;
 	if (!(outline.mem = dm_pool_create("config_line", 1024)))
 		return_0;
 	outline.putline = putline;
@@ -471,57 +466,6 @@
 	return 1;
 }
 
-int dm_config_write(struct dm_config_tree *cft, const char *file,
-		    int argc, char **argv)
-{
-	const struct dm_config_node *cn;
-	int r = 1;
-	struct output_line outline;
-	outline.fp = NULL;
-	outline.putline = NULL;
-
-// FIXME AGK remove the fopen from libdm before release
-	if (!file)
-		file = "stdout";
-	else if (!(outline.fp = fopen(file, "w"))) {
-		log_sys_error("open", file);
-		return 0;
-	}
-
-	if (!(outline.mem = dm_pool_create("config_line", 1024))) {
-		r = 0;
-		goto_out;
-	}
-
-	log_verbose("Dumping configuration to %s", file);
-	if (!argc) {
-		if (!_write_config(cft->root, 0, &outline, 0)) {
-			log_error("Failure while writing to %s", file);
-			r = 0;
-		}
-	} else while (argc--) {
-		if ((cn = dm_config_find_node(cft->root, *argv))) {
-			if (!_write_config(cn, 1, &outline, 0)) {
-				log_error("Failure while writing to %s", file);
-				r = 0;
-			}
-		} else {
-			log_error("Configuration node %s not found", *argv);
-			r = 0;
-		}
-		argv++;
-	}
-
-	dm_pool_destroy(outline.mem);
-
-out:
-	if (outline.fp && dm_fclose(outline.fp)) {
-		stack;
-		r = 0;
-	}
-
-	return r;
-}
 
 /*
  * parser
--- LVM2/lib/config/config.c	2011/10/28 20:06:49	1.108
+++ LVM2/lib/config/config.c	2011/12/11 23:18:20	1.109
@@ -324,3 +324,51 @@
 	return 1;
 }
 
+static int _putline_fn(const char *line, void *baton) {
+	FILE *fp = baton;
+	fprintf(fp, "%s\n", line);
+	return 1;
+};
+
+int config_write(struct dm_config_tree *cft, const char *file,
+		 int argc, char **argv)
+{
+	const struct dm_config_node *cn;
+	int r = 1;
+	FILE *fp = NULL;
+
+	if (!file) {
+		fp = stdout;
+		file = "stdout";
+	} else if (!(fp = fopen(file, "w"))) {
+		log_sys_error("open", file);
+		return 0;
+	}
+
+	log_verbose("Dumping configuration to %s", file);
+	if (!argc) {
+		if (!dm_config_write_node(cft->root, _putline_fn, fp)) {
+			log_error("Failure while writing to %s", file);
+			r = 0;
+		}
+	} else while (argc--) {
+		if ((cn = dm_config_find_node(cft->root, *argv))) {
+			if (!dm_config_write_node(cn, _putline_fn, fp)) {
+				log_error("Failure while writing to %s", file);
+				r = 0;
+			}
+		} else {
+			log_error("Configuration node %s not found", *argv);
+			r = 0;
+		}
+		argv++;
+	}
+
+out:
+	if (fp && dm_fclose(fp)) {
+		stack;
+		r = 0;
+	}
+
+	return r;
+}
--- LVM2/lib/config/config.h	2011/10/28 20:06:49	1.38
+++ LVM2/lib/config/config.h	2011/12/11 23:18:20	1.39
@@ -32,6 +32,9 @@
 		   off_t offset, size_t size, off_t offset2, size_t size2,
 		   checksum_fn_t checksum_fn, uint32_t checksum);
 
+int config_write(struct dm_config_tree *cft, const char *file,
+		 int argc, char **argv);
+
 int read_config_file(struct dm_config_tree *cft);
 
 int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
--- LVM2/tools/dumpconfig.c	2011/08/30 14:55:19	1.10
+++ LVM2/tools/dumpconfig.c	2011/12/11 23:18:20	1.11
@@ -19,7 +19,7 @@
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
 
-	if (!dm_config_write(cmd->cft, file, argc, argv)) {
+	if (!config_write(cmd->cft, file, argc, argv)) {
 		stack;
 		return ECMD_FAILED;
 	}


