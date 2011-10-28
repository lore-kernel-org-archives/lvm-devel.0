From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:06:51 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/commands/t ...
Message-ID: <20111028200651.23306.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:06:50

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/commands   : toolcontext.c 
	lib/config     : config.c config.h 
	libdm          : libdevmapper.h libdm-config.c 

Log message:
	Add find_config_tree_str_allow_empty
	
	Add function to allow read of empty strings as valid arguments.
	Add a warning message if string argument has ignored value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2172&r2=1.2173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.518&r2=1.519
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/10/25 13:17:04	1.2172
+++ LVM2/WHATS_NEW	2011/10/28 20:06:49	1.2173
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Support empty string for log/prefix.
   Fix regression that allowed mirrored logs for cluster mirrors.
   Don't print char type[8] as a plain string in pvck PV type.
   Use vg memory pool implicitely for vg read.
--- LVM2/WHATS_NEW_DM	2011/10/23 15:38:02	1.518
+++ LVM2/WHATS_NEW_DM	2011/10/28 20:06:49	1.519
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add dm_config_tree_find_str_allow_empty.
   Fix compile-time pool memory locking with DEBUG_MEM.
   Fix valgrind error reports in free of pool chunks with DEBUG_MEM.
   Align size of structure chunk for fast pool allocator to 8 bytes.
--- LVM2/lib/commands/toolcontext.c	2011/10/11 09:09:00	1.138
+++ LVM2/lib/commands/toolcontext.c	2011/10/28 20:06:49	1.139
@@ -153,9 +153,9 @@
 	init_abort_on_internal_errors(find_config_tree_int(cmd, "global/abort_on_internal_errors",
 							   DEFAULT_ABORT_ON_INTERNAL_ERRORS));
 
-	cmd->default_settings.msg_prefix = find_config_tree_str(cmd,
-							   "log/prefix",
-							   DEFAULT_MSG_PREFIX);
+	cmd->default_settings.msg_prefix =
+		find_config_tree_str_allow_empty(cmd, "log/prefix", DEFAULT_MSG_PREFIX);
+
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 
 	cmd->default_settings.cmd_name = find_config_tree_int(cmd,
--- LVM2/lib/config/config.c	2011/10/11 09:06:09	1.107
+++ LVM2/lib/config/config.c	2011/10/28 20:06:49	1.108
@@ -183,6 +183,12 @@
 	return dm_config_tree_find_str(cmd->cft, path, fail);
 }
 
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd,
+					     const char *path, const char *fail)
+{
+	return dm_config_tree_find_str_allow_empty(cmd->cft, path, fail);
+}
+
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail)
 {
--- LVM2/lib/config/config.h	2011/09/02 01:32:09	1.37
+++ LVM2/lib/config/config.h	2011/10/28 20:06:49	1.38
@@ -44,6 +44,8 @@
 						   const char *path);
 const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail);
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd,
+					     const char *path, const char *fail);
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail);
 int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path,
--- LVM2/libdm/libdevmapper.h	2011/10/28 20:04:17	1.165
+++ LVM2/libdm/libdevmapper.h	2011/10/28 20:06:50	1.166
@@ -1385,6 +1385,8 @@
 const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tree *cft, const char *path);
 const char *dm_config_tree_find_str(const struct dm_config_tree *cft,
 				    const char *path, const char *fail);
+const char *dm_config_tree_find_str_allow_empty(const struct dm_config_tree *cft,
+						const char *path, const char *fail);
 int dm_config_tree_find_int(const struct dm_config_tree *cft,
 			    const char *path, int fail);
 int64_t dm_config_tree_find_int64(const struct dm_config_tree *cft,
--- LVM2/libdm/libdm-config.c	2011/09/25 19:45:40	1.13
+++ LVM2/libdm/libdm-config.c	2011/10/28 20:06:50	1.14
@@ -919,15 +919,18 @@
 }
 
 static const char *_find_config_str(const void *start, node_lookup_fn find_fn,
-				    const char *path, const char *fail)
+				    const char *path, const char *fail, int allow_empty)
 {
 	const struct dm_config_node *n = find_fn(start, path);
 
 	/* Empty strings are ignored */
-	if ((n && n->v && n->v->type == DM_CFG_STRING) && (*n->v->v.str)) {
+	if ((n && n->v && n->v->type == DM_CFG_STRING) &&
+	    (allow_empty || (*n->v->v.str))) {
 		log_very_verbose("Setting %s to %s", path, n->v->v.str);
 		return n->v->v.str;
-	}
+	} else if (n && (!n->v || (n->v->type != DM_CFG_STRING) ||
+			 (!allow_empty && fail)))
+		log_warn("WARNING: Ignoring unsupported value for %s.", path);
 
 	if (fail)
 		log_very_verbose("%s not found in config: defaulting to %s",
@@ -938,7 +941,7 @@
 const char *dm_config_find_str(const struct dm_config_node *cn,
 			       const char *path, const char *fail)
 {
-	return _find_config_str(cn, _find_config_node, path, fail);
+	return _find_config_str(cn, _find_config_node, path, fail, 0);
 }
 
 static int64_t _find_config_int64(const void *start, node_lookup_fn find,
@@ -1060,7 +1063,13 @@
 const char *dm_config_tree_find_str(const struct dm_config_tree *cft, const char *path,
 				    const char *fail)
 {
-	return _find_config_str(cft, _find_first_config_node, path, fail);
+	return _find_config_str(cft, _find_first_config_node, path, fail, 0);
+}
+
+const char *dm_config_tree_find_str_allow_empty(const struct dm_config_tree *cft, const char *path,
+						const char *fail)
+{
+	return _find_config_str(cft, _find_first_config_node, path, fail, 1);
 }
 
 int dm_config_tree_find_int(const struct dm_config_tree *cft, const char *path, int fail)


