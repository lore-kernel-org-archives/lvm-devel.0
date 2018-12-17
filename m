From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:10 -0500
Subject: master - lvm: drop usage of dl library
Message-ID: <201812171008.wBHA8AfB024756@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=701ecff0ff2c1a3d194a6d94b16b9ce6f0a2ba22
Commit:        701ecff0ff2c1a3d194a6d94b16b9ce6f0a2ba22
Parent:        8bf445b2deed25f101e2861656ee19151ea7e335
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 21:51:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

lvm: drop usage of dl library

Since lvm no longer supports any dlopen-able plugins
(which in practice was never really usable) drop linking
with -ldl.
---
 lib/Makefile.in            |   11 +-----
 lib/commands/toolcontext.c |   93 --------------------------------------------
 lib/misc/sharedlib.c       |   30 +--------------
 lib/misc/sharedlib.h       |    3 -
 make.tmpl.in               |    2 +-
 test/unit/Makefile         |    2 +-
 6 files changed, 4 insertions(+), 137 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 722e954..bde66f9 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -91,6 +91,7 @@ SOURCES =\
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
 	misc/lvm-percent.c \
+	misc/sharedlib.c \
 	mm/memlock.c \
 	notify/lvmnotify.c \
 	properties/prop_common.c \
@@ -109,10 +110,6 @@ ifeq ("@DEVMAPPER@", "yes")
 	activate/fs.c
 endif
 
-ifeq ("@HAVE_LIBDL@", "yes")
-  SOURCES += misc/sharedlib.c
-endif
-
 ifeq ("@BUILD_LVMPOLLD@", "yes")
   SOURCES +=\
 	lvmpolld/lvmpolld-client.c
@@ -130,12 +127,6 @@ endif
 LIB_NAME = liblvm-internal
 LIB_STATIC = $(LIB_NAME).a
 
-ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS =\
-	notify \
-	locking
-endif
-
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c42ed56..63eafe8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -32,10 +32,6 @@
 #include "lib/format_text/archiver.h"
 #include "lib/lvmpolld/lvmpolld-client.h"
 
-#ifdef HAVE_LIBDL
-#include "lib/misc/sharedlib.h"
-#endif
-
 #include <locale.h>
 #include <sys/stat.h>
 #include <sys/syscall.h>
@@ -1276,24 +1272,6 @@ int lvm_register_segtype(struct segtype_library *seglib,
 	return 1;
 }
 
-static int _init_single_segtype(struct cmd_context *cmd,
-				struct segtype_library *seglib)
-{
-	struct segment_type *(*init_segtype_fn) (struct cmd_context *);
-	struct segment_type *segtype;
-
-	if (!(init_segtype_fn = dlsym(seglib->lib, "init_segtype"))) {
-		log_error("Shared library %s does not contain segment type "
-			  "functions", seglib->libname);
-		return 0;
-	}
-
-	if (!(segtype = init_segtype_fn(seglib->cmd)))
-		return_0;
-
-	return lvm_register_segtype(seglib, segtype);
-}
-
 static int _init_segtypes(struct cmd_context *cmd)
 {
 	int i;
@@ -1314,10 +1292,6 @@ static int _init_segtypes(struct cmd_context *cmd)
 		NULL
 	};
 
-#ifdef HAVE_LIBDL
-	const struct dm_config_node *cn;
-#endif
-
 	for (i = 0; init_segtype_array[i]; i++) {
 		if (!(segtype = init_segtype_array[i](cmd)))
 			return 0;
@@ -1350,57 +1324,6 @@ static int _init_segtypes(struct cmd_context *cmd)
 		return 0;
 #endif
 
-#ifdef HAVE_LIBDL
-	/* Load any formats in shared libs unless static */
-	if (!is_static() &&
-	    (cn = find_config_tree_array(cmd, global_segment_libraries_CFG, NULL))) {
-
-		const struct dm_config_value *cv;
-		int (*init_multiple_segtypes_fn) (struct cmd_context *,
-						  struct segtype_library *);
-
-		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Invalid string in config file: "
-					  "global/segment_libraries");
-				return 0;
-			}
-			seglib.libname = cv->v.str;
-			if (!(seglib.lib = load_shared_library(cmd,
-							seglib.libname,
-							"segment type", 0)))
-				return_0;
-
-			if ((init_multiple_segtypes_fn =
-			    dlsym(seglib.lib, "init_multiple_segtypes"))) {
-				if (dlsym(seglib.lib, "init_segtype"))
-					log_warn("WARNING: Shared lib %s has "
-						 "conflicting init fns.  Using"
-						 " init_multiple_segtypes().",
-						 seglib.libname);
-			} else
-				init_multiple_segtypes_fn =
-				    _init_single_segtype;
- 
-			if (!init_multiple_segtypes_fn(cmd, &seglib)) {
-				struct dm_list *sgtl, *tmp;
-				log_error("init_multiple_segtypes() failed: "
-					  "Unloading shared library %s",
-					  seglib.libname);
-				dm_list_iterate_safe(sgtl, tmp, &cmd->segtypes) {
-					segtype = dm_list_item(sgtl, struct segment_type);
-					if (segtype->library == seglib.lib) {
-						dm_list_del(&segtype->list);
-						segtype->ops->destroy(segtype);
-					}
-				}
-				dlclose(seglib.lib);
-				return_0;
-			}
-		}
-	}
-#endif
-
 	return 1;
 }
 
@@ -1797,27 +1720,11 @@ static void _destroy_segtypes(struct dm_list *segtypes)
 {
 	struct dm_list *sgtl, *tmp;
 	struct segment_type *segtype;
-	void *lib;
 
 	dm_list_iterate_safe(sgtl, tmp, segtypes) {
 		segtype = dm_list_item(sgtl, struct segment_type);
 		dm_list_del(&segtype->list);
-		lib = segtype->library;
 		segtype->ops->destroy(segtype);
-#ifdef HAVE_LIBDL
-		/*
-		 * If no segtypes remain from this library, close it.
-		 */
-		if (lib) {
-			struct segment_type *segtype2;
-			dm_list_iterate_items(segtype2, segtypes)
-				if (segtype2->library == lib)
-					goto skip_dlclose;
-			dlclose(lib);
-skip_dlclose:
-			;
-		}
-#endif
 	}
 }
 
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index 4c2d5d9..544bb5f 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -14,8 +14,8 @@
  */
 
 #include "lib/misc/lib.h"
+#include "sharedlib.h"
 #include "lib/config/config.h"
-#include "lib/misc/sharedlib.h"
 #include "lib/commands/toolcontext.h"
 
 #include <limits.h>
@@ -40,31 +40,3 @@ void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 		(void) dm_strncpy(path, libname, path_len);
 	}
 }
-
-void *load_shared_library(struct cmd_context *cmd, const char *libname,
-			  const char *desc, int silent)
-{
-	char path[PATH_MAX];
-	void *library;
-
-	if (is_static()) {
-		log_error("Not loading shared %s library %s in static mode.",
-			  desc, libname);
-		return NULL;
-	}
-
-	get_shared_library_path(cmd, libname, path, sizeof(path));
-
-	log_very_verbose("Opening shared %s library %s", desc, path);
-
-	if (!(library = dlopen(path, RTLD_LAZY | RTLD_GLOBAL))) {
-		if (silent)
-			log_verbose("Unable to open external %s library %s: %s",
-				    desc, path, dlerror());
-		else
-			log_error("Unable to open external %s library %s: %s",
-				  desc, path, dlerror());
-	}
-
-	return library;
-}
diff --git a/lib/misc/sharedlib.h b/lib/misc/sharedlib.h
index 5ff2dcb..23f2acc 100644
--- a/lib/misc/sharedlib.h
+++ b/lib/misc/sharedlib.h
@@ -21,7 +21,4 @@
 
 void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 			     char *path, size_t path_len);
-void *load_shared_library(struct cmd_context *cmd, const char *libname,
-			  const char *what, int silent);
-
 #endif
diff --git a/make.tmpl.in b/make.tmpl.in
index 1a101fc..13f9afc 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -75,7 +75,7 @@ LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS=\
 	-llvm-internal \
-	$(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
+	$(DAEMON_LIBS) $(DMEVENT_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 0ba98ee..fa6acb6 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -41,7 +41,7 @@ CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
 test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(DMEVENT_LIBS) $(SYSTEMD_LIBS) $(LIBS) -ldl -laio
+	      -o $@ $+ $(DMEVENT_LIBS) $(SYSTEMD_LIBS) $(LIBS) -laio
 
 .PHONEY: run-unit-test unit-test
 unit-test: test/unit/unit-test


