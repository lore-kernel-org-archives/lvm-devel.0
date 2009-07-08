From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2009 12:36:02 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20090708123602.27413.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-08 12:36:01

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/metadata   : segtype.h 

Log message:
	Permit several segment types to be registered by a single shared object.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1166&r2=1.1167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2009/07/06 19:17:15	1.1166
+++ LVM2/WHATS_NEW	2009/07/08 12:36:01	1.1167
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Permit several segment types to be registered by a single shared object.
   Update the man pages to document size units uniformly.
   Allow commandline sizes to be specified in terms of bytes and sectors.
   Update 'md_chunk_alignment' to use stripe-width to align PV data area.
--- LVM2/lib/commands/toolcontext.c	2009/06/17 20:54:20	1.76
+++ LVM2/lib/commands/toolcontext.c	2009/07/08 12:36:01	1.77
@@ -806,12 +806,59 @@
 	return 1;
 }
 
+struct segtype_library {
+	struct cmd_context *cmd;
+	void *lib;
+	const char *libname;
+};
+
+int lvm_register_segtype(struct segtype_library *seglib,
+			 struct segment_type *segtype)
+{
+	struct segment_type *segtype2;
+
+	segtype->library = seglib->lib;
+	segtype->cmd = seglib->cmd;
+
+	dm_list_iterate_items(segtype2, &seglib->cmd->segtypes) {
+		if (strcmp(segtype2->name, segtype->name))
+			continue;
+		log_error("Duplicate segment type %s: "
+			  "unloading shared library %s",
+			  segtype->name, seglib->libname);
+		segtype->ops->destroy(segtype);
+		return 0;
+	}
+
+	dm_list_add(&seglib->cmd->segtypes, &segtype->list);
+
+	return 1;
+}
+
+static int _init_single_segtype(struct segtype_library *seglib)
+{
+	struct segment_type *(*init_segtype_fn) (struct cmd_context *);
+	struct segment_type *segtype;
+
+	if (!(init_segtype_fn = dlsym(seglib->lib, "init_segtype"))) {
+		log_error("Shared library %s does not contain segment type "
+			  "functions", seglib->libname);
+		return 0;
+	}
+
+	if (!(segtype = init_segtype_fn(seglib->cmd)))
+		return_0;
+
+	return lvm_register_segtype(seglib, segtype);
+}
+
 static int _init_segtypes(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;
 
 #ifdef HAVE_LIBDL
 	const struct config_node *cn;
+	struct segtype_library seglib;
 #endif
 
 	if (!(segtype = init_striped_segtype(cmd)))
@@ -854,9 +901,9 @@
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
 		struct config_value *cv;
-		struct segment_type *(*init_segtype_fn) (struct cmd_context *);
-		void *lib;
-		struct segment_type *segtype2;
+		int (*init_multiple_segtypes_fn) (struct segtype_library *);
+
+		seglib.cmd = cmd;
 
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
@@ -864,32 +911,37 @@
 					  "global/segment_libraries");
 				return 0;
 			}
-			if (!(lib = load_shared_library(cmd, cv->v.str,
+			seglib.libname = cv->v.str;
+			if (!(seglib.lib = load_shared_library(cmd,
+							seglib.libname,
 							"segment type", 0)))
 				return_0;
 
-			if (!(init_segtype_fn = dlsym(lib, "init_segtype"))) {
-				log_error("Shared library %s does not contain "
-					  "segment type functions", cv->v.str);
-				dlclose(lib);
-				return 0;
-			}
-
-			if (!(segtype = init_segtype_fn(cmd)))
-				return 0;
-			segtype->library = lib;
-			dm_list_add(&cmd->segtypes, &segtype->list);
-
-			dm_list_iterate_items(segtype2, &cmd->segtypes) {
-				if ((segtype == segtype2) ||
-				     strcmp(segtype2->name, segtype->name))
-					continue;
-				log_error("Duplicate segment type %s: "
-					  "unloading shared library %s",
-					  segtype->name, cv->v.str);
-				dm_list_del(&segtype->list);
-				segtype->ops->destroy(segtype);
-				dlclose(lib);
+			if ((init_multiple_segtypes_fn =
+			    dlsym(seglib.lib, "init_multiple_segtypes"))) {
+				if (dlsym(seglib.lib, "init_segtype"))
+					log_warn("WARNING: Shared lib %s has "
+						 "conflicting init fns.  Using"
+						 " init_multiple_segtypes().",
+						 seglib.libname);
+			} else
+				init_multiple_segtypes_fn =
+				    _init_single_segtype;
+ 
+			if (!init_multiple_segtypes_fn(&seglib)) {
+				struct dm_list *sgtl, *tmp;
+				log_error("init_multiple_segtypes() failed: "
+					  "Unloading shared library %s",
+					  seglib.libname);
+				dm_list_iterate_safe(sgtl, tmp, &cmd->segtypes) {
+					segtype = dm_list_item(sgtl, struct segment_type);
+					if (segtype->library == seglib.lib) {
+						dm_list_del(&segtype->list);
+						segtype->ops->destroy(segtype);
+					}
+				}
+				dlclose(seglib.lib);
+				return_0;
 			}
 		}
 	}
@@ -1154,8 +1206,18 @@
 		lib = segtype->library;
 		segtype->ops->destroy(segtype);
 #ifdef HAVE_LIBDL
-		if (lib)
+		/*
+		 * If no segtypes remain from this library, close it.
+		 */
+		if (lib) {
+			struct segment_type *segtype2;
+			dm_list_iterate_items(segtype2, segtypes)
+				if (segtype2->library == lib)
+					goto skip_dlclose;
 			dlclose(lib);
+skip_dlclose:
+			;
+		}
 #endif
 	}
 }
--- LVM2/lib/metadata/segtype.h	2009/02/28 20:04:25	1.23
+++ LVM2/lib/metadata/segtype.h	2009/07/08 12:36:01	1.24
@@ -47,13 +47,13 @@
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {
-	struct dm_list list;
-	struct cmd_context *cmd;
+	struct dm_list list;		/* Internal */
+	struct cmd_context *cmd;	/* lvm_register_segtype() sets this. */
 	uint32_t flags;
 	struct segtype_handler *ops;
 	const char *name;
-	void *library;
-	void *private;
+	void *library;			/* lvm_register_segtype() sets this. */
+	void *private;			/* For the segtype handler to use. */
 };
 
 struct segtype_handler {
@@ -93,6 +93,10 @@
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 					     const char *str);
 
+struct segtype_library;
+int lvm_register_segtype(struct segtype_library *seglib,
+			 struct segment_type *segtype);
+
 struct segment_type *init_striped_segtype(struct cmd_context *cmd);
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);


