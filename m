From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jan 2007 23:22:32 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/confi ...
Message-ID: <20070109232232.17425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-09 23:22:32

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c config.h 
	tools          : commands.h dumpconfig.c 

Log message:
	dumpconfig accepts a list of configuration variables to display.
	Change dumpconfig to use --file to redirect output to a file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.531&r2=1.532
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2007/01/09 23:14:35	1.531
+++ LVM2/WHATS_NEW	2007/01/09 23:22:31	1.532
@@ -1,5 +1,7 @@
 Version 2.02.18 -
 ====================================
+  dumpconfig accepts a list of configuration variables to display.
+  Change dumpconfig to use --file to redirect output to a file.
   Avoid vgreduce error when mirror code removes the log LV.
   Remove 3 redundant AC_MSG_RESULTs from configure.in.
   Free memory in _raw_read_mda_header() error paths.
--- LVM2/lib/config/config.c	2006/11/21 15:13:36	1.50
+++ LVM2/lib/config/config.c	2007/01/09 23:22:31	1.51
@@ -373,7 +373,8 @@
 	}
 }
 
-static int _write_config(struct config_node *n, FILE *fp, int level)
+static int _write_config(struct config_node *n, int only_one, FILE *fp,
+			 int level)
 {
 	char space[MAX_INDENT + 1];
 	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
@@ -386,12 +387,12 @@
 		space[i] = '\t';
 	space[i] = '\0';
 
-	while (n) {
+	do {
 		fprintf(fp, "%s%s", space, n->key);
 		if (!n->v) {
 			/* it's a sub section */
 			fprintf(fp, " {\n");
-			_write_config(n->child, fp, level + 1);
+			_write_config(n->child, 0, fp, level + 1);
 			fprintf(fp, "%s}", space);
 		} else {
 			/* it's a value */
@@ -411,13 +412,15 @@
 		}
 		fprintf(fp, "\n");
 		n = n->sib;
-	}
+	} while (n && !only_one);
 	/* FIXME: add error checking */
 	return 1;
 }
 
-int write_config_file(struct config_tree *cft, const char *file)
+int write_config_file(struct config_tree *cft, const char *file,
+		      int argc, char **argv)
 {
+	struct config_node *cn;
 	int r = 1;
 	FILE *fp;
 
@@ -430,9 +433,22 @@
 	}
 
 	log_verbose("Dumping configuration to %s", file);
-	if (!_write_config(cft->root, fp, 0)) {
-		log_error("Failure while writing configuration");
-		r = 0;
+	if (!argc) {
+		if (!_write_config(cft->root, 0, fp, 0)) {
+			log_error("Failure while writing configuration");
+			r = 0;
+		}
+	} else while (argc--) {
+		if ((cn = find_config_node(cft->root, *argv))) {
+			if (!_write_config(cn, 1, fp, 0)) {
+				log_error("Failure while writing configuration");
+				r = 0;
+			}
+		} else {
+			log_error("Configuration node %s not found", *argv);
+			r = 0;
+		}
+		argv++;
 	}
 
 	if (fp != stdout)
--- LVM2/lib/config/config.h	2006/11/04 03:34:09	1.21
+++ LVM2/lib/config/config.h	2007/01/09 23:22:31	1.22
@@ -65,7 +65,8 @@
 		   checksum_fn_t checksum_fn, uint32_t checksum);
 
 int read_config_file(struct config_tree *cft);
-int write_config_file(struct config_tree *cft, const char *file);
+int write_config_file(struct config_tree *cft, const char *file,
+		      int argc, char **argv);
 time_t config_file_timestamp(struct config_tree *cft);
 int config_file_changed(struct config_tree *cft);
 int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
--- LVM2/tools/commands.h	2006/11/10 18:24:11	1.92
+++ LVM2/tools/commands.h	2007/01/09 23:22:31	1.93
@@ -30,7 +30,10 @@
 
 xx(dumpconfig,
    "Dump active configuration",
-   "dumpconfig <filename>\n")
+   "dumpconfig "
+   "\t[-f|--file filename] " "\n"
+   "[ConfigurationVariable...]\n",
+   file_ARG)
 
 xx(formats,
    "List available metadata formats",
--- LVM2/tools/dumpconfig.c	2004/03/30 19:35:42	1.4
+++ LVM2/tools/dumpconfig.c	2007/01/09 23:22:31	1.5
@@ -19,15 +19,10 @@
 {
 	const char *file = NULL;
 
-	if (argc == 1)
-		file = argv[0];
+	if (arg_count(cmd, file_ARG))
+		file = arg_str_value(cmd, file_ARG, "");
 
-	if (argc > 1) {
-		log_error("Please specify one file for output");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!write_config_file(cmd->cft, file))
+	if (!write_config_file(cmd->cft, file, argc, argv))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;


