From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 25 Jun 2009 10:04:14 -0400 (EDT)
Subject: [PATCH] more segtypes in one library
Message-ID: <Pine.LNX.4.64.0906250938160.6612@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

This is the patch for more segtypes in one shared library. You define 
function init_segtypes (instead of init_segtype) and this function can 
register arbitraty number of segtypes with lvm_add_segtype. It returns 
nonzero on success or zero on failure (in this case, the registered 
segtypes are destroyed and the library is unloaded).

The old function init_segtype to init one segtype is still available, so 
it doesn't break binary compatibility.

Mikulas


---
 lib/commands/toolcontext.c |   97 ++++++++++++++++++++++++++++++++-------------
 lib/metadata/segtype.h     |    2 
 2 files changed, 72 insertions(+), 27 deletions(-)

Index: LVM2.2.02.47/lib/commands/toolcontext.c
===================================================================
--- LVM2.2.02.47.orig/lib/commands/toolcontext.c	2009-06-23 12:32:08.000000000 +0200
+++ LVM2.2.02.47/lib/commands/toolcontext.c	2009-06-25 16:02:14.000000000 +0200
@@ -809,6 +809,47 @@ int init_lvmcache_orphans(struct cmd_con
 	return 1;
 }
 
+static void *current_library = NULL;
+
+int lvm_add_segtype(struct cmd_context *cmd, struct segment_type *segtype)
+{
+	struct segment_type *segtype2;
+
+	segtype->library = current_library;
+	dm_list_iterate_items(segtype2, &cmd->segtypes) {
+		if (strcmp(segtype2->name, segtype->name))
+			continue;
+		log_error("Duplicate segment type %s: unloading shared library",
+			  segtype->name);
+		segtype->ops->destroy(segtype);
+		return 0;
+	}
+
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	return 1;
+}
+
+static int init_segtypes_legacy(struct cmd_context *cmd)
+{
+	struct segment_type *(*init_segtype_fn) (struct cmd_context *);
+	struct segment_type *segtype;
+
+	init_segtype_fn = dlsym(current_library, "init_segtype");
+	if (!init_segtype_fn) {
+		log_error("Shared library does not contain segment type "
+			  "functions");
+		return 0;
+	}
+
+	segtype = init_segtype_fn(cmd);
+
+	if (!segtype)
+		return 0;
+
+	return lvm_add_segtype(cmd, segtype);
+}
+
 static int _init_segtypes(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;
@@ -857,9 +898,7 @@ static int _init_segtypes(struct cmd_con
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
 		struct config_value *cv;
-		struct segment_type *(*init_segtype_fn) (struct cmd_context *);
-		void *lib;
-		struct segment_type *segtype2;
+		int (*init_segtypes_fn) (struct cmd_context *);
 
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
@@ -867,33 +906,31 @@ static int _init_segtypes(struct cmd_con
 					  "global/segment_libraries");
 				return 0;
 			}
-			if (!(lib = load_shared_library(cmd, cv->v.str,
-							"segment type", 0)))
+			if (!(current_library = load_shared_library(cmd,
+						cv->v.str, "segment type", 0)))
 				return_0;
 
-			if (!(init_segtype_fn = dlsym(lib, "init_segtype"))) {
-				log_error("Shared library %s does not contain "
-					  "segment type functions", cv->v.str);
-				dlclose(lib);
-				return 0;
+			if (!(init_segtypes_fn = dlsym(current_library,
+							"init_segtypes")))
+				init_segtypes_fn = init_segtypes_legacy;
+
+			if (!init_segtypes_fn(cmd)) {
+				struct dm_list *sgtl, *tmp;
+				log_error("Unloading shared library %s",
+					  cv->v.str);
+				dm_list_iterate_safe(sgtl, tmp, &cmd->segtypes) {
+					segtype = dm_list_item(sgtl, struct segment_type);
+					if (segtype->library == current_library) {
+						dm_list_del(&segtype->list);
+						segtype->ops->destroy(segtype);
+					}
+				}
+				dlclose(current_library);
+				current_library = NULL;
+				return_0;
 			}
 
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
-			}
+			current_library = NULL;
 		}
 	}
 #endif
@@ -1170,8 +1207,14 @@ static void _destroy_segtypes(struct dm_
 		lib = segtype->library;
 		segtype->ops->destroy(segtype);
 #ifdef HAVE_LIBDL
-		if (lib)
+		if (lib) {
+			struct segment_type *segtype2;
+			dm_list_iterate_items(segtype2, segtypes)
+				if (segtype2->library == lib)
+					goto skip_dlclose;
 			dlclose(lib);
+skip_dlclose:;
+		}
 #endif
 	}
 }
Index: LVM2.2.02.47/lib/metadata/segtype.h
===================================================================
--- LVM2.2.02.47.orig/lib/metadata/segtype.h	2009-06-23 12:32:08.000000000 +0200
+++ LVM2.2.02.47/lib/metadata/segtype.h	2009-06-25 16:01:45.000000000 +0200
@@ -99,6 +99,8 @@ struct segtype_handler {
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 					     const char *str);
 
+int lvm_add_segtype(struct cmd_context *cmd, struct segment_type *segtype);
+
 struct segment_type *init_striped_segtype(struct cmd_context *cmd);
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);


