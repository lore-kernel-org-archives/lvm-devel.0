From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Apr 2007 20:41:50 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/confi ...
Message-ID: <20070427204150.14814.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-27 21:41:50

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c config.h 

Log message:
	Fix get_config_uint64() to read a 64-bit value not a 32-bit one.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.610&r2=1.611
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2007/04/27 19:26:56	1.610
+++ LVM2/WHATS_NEW	2007/04/27 20:41:49	1.611
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Fix get_config_uint64() to read a 64-bit value not a 32-bit one.
   Add -Wformat-security and change one fprintf() to fputs().
   Move regex functions into libdevmapper.
   Change some #include lines to search only standard system directories.
--- LVM2/lib/config/config.c	2007/04/26 16:40:46	1.57
+++ LVM2/lib/config/config.c	2007/04/27 20:41:50	1.58
@@ -357,7 +357,7 @@
 		break;
 
 	case CFG_INT:
-		fprintf(fp, "%d", v->v.i);
+		fprintf(fp, "%" PRId64, v->v.i);
 		break;
 
 	case CFG_EMPTY_ARRAY:
@@ -568,7 +568,7 @@
 	switch (p->t) {
 	case TOK_INT:
 		v->type = CFG_INT;
-		v->v.i = strtol(p->tb, NULL, 0);	/* FIXME: check error */
+		v->v.i = strtoll(p->tb, NULL, 0);	/* FIXME: check error */
 		match(TOK_INT);
 		break;
 
@@ -871,25 +871,26 @@
 	return _find_config_str(cn, NULL, path, fail);
 }
 
-static int _find_config_int(const struct config_node *cn1,
-			    const struct config_node *cn2,
-			    const char *path, int fail)
+static int64_t _find_config_int64(const struct config_node *cn1,
+				  const struct config_node *cn2,
+				  const char *path, int64_t fail)
 {
 	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
 
 	if (n && n->v && n->v->type == CFG_INT) {
-		log_very_verbose("Setting %s to %d", path, n->v->v.i);
+		log_very_verbose("Setting %s to %" PRId64, path, n->v->v.i);
 		return n->v->v.i;
 	}
 
-	log_very_verbose("%s not found in config: defaulting to %d",
+	log_very_verbose("%s not found in config: defaulting to %" PRId64,
 			 path, fail);
 	return fail;
 }
 
 int find_config_int(const struct config_node *cn, const char *path, int fail)
 {
-	return _find_config_int(cn, NULL, path, fail);
+	/* FIXME Add log_error message on overflow */
+	return (int) _find_config_int64(cn, NULL, path, (int64_t) fail);
 }
 
 static float _find_config_float(const struct config_node *cn1,
@@ -931,7 +932,8 @@
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
                          int fail)
 {
-	return _find_config_int(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
+	/* FIXME Add log_error message on overflow */
+	return (int) _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, (int64_t) fail);
 }
 
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
@@ -1023,7 +1025,6 @@
 	if (!n || !n->v || n->v->type != CFG_INT)
 		return 0;
 
-	/* FIXME Support 64-bit value! */
 	*result = (uint64_t) n->v->v.i;
 	return 1;
 }
--- LVM2/lib/config/config.h	2007/04/25 20:38:39	1.23
+++ LVM2/lib/config/config.h	2007/04/27 20:41:50	1.24
@@ -31,7 +31,7 @@
 struct config_value {
 	int type;
 	union {
-		int i;
+		int64_t i;
 		float r;
 		char *str;
 	} v;


