From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Dec 2013 10:18:51 +0000 (UTC)
Subject: master - cleanup: tiny speedup of lib_dir checking
Message-ID: <20131210101851.1A6E3601DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f0e27a18c60193feae83e458f821efc6ac64683
Commit:        9f0e27a18c60193feae83e458f821efc6ac64683
Parent:        0fcdc8a020afcafa182da93922c171604cf3035e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 6 16:35:54 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 11:15:48 2013 +0100

cleanup: tiny speedup of lib_dir checking

Instead of repeated lookup of global/library_dir - remember first
search in command context - saves couple lines in debug output...
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    2 ++
 lib/commands/toolcontext.h |    1 +
 lib/misc/sharedlib.c       |    7 ++++---
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 633f4d8..2596509 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Cache global library dir in command context.
   Return success when inserting dirs and links into device cache.
   Test for remote exclusive activation after activation fails.
   Support lvconvert --merge for thin snapshots.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d13d8d5..9d6ef5e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1654,6 +1654,8 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	cmd->hosttags = 0;
 
+	cmd->lib_dir = NULL;
+
 	if (!_init_lvm_conf(cmd))
 		return 0;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 74b1177..7a50e1e 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -121,6 +121,7 @@ struct cmd_context {
 	struct dm_list tags;
 	int hosttags;
 
+	const char *lib_dir;		/* Cache value global/library_dir */
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index fca079b..db98da1 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "config.h"
 #include "sharedlib.h"
+#include "toolcontext.h"
 
 #include <limits.h>
 #include <sys/stat.h>
@@ -25,13 +26,13 @@ void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 			     char *path, size_t path_len)
 {
 	struct stat info;
-	const char *lib_dir;
 
 	/* If libname doesn't begin with '/' then use lib_dir/libname,
 	 * if present */
 	if (libname[0] == '/' ||
-	    !(lib_dir = find_config_tree_str(cmd, global_library_dir_CFG, NULL)) ||
-	    (dm_snprintf(path, path_len, "%s/%s", lib_dir,
+            (!cmd->lib_dir &&
+	     !(cmd->lib_dir = find_config_tree_str(cmd, global_library_dir_CFG, NULL))) ||
+	    (dm_snprintf(path, path_len, "%s/%s", cmd->lib_dir,
 			 libname) == -1) || stat(path, &info) == -1) {
 		strncpy(path, libname, path_len - 1);
 		path[path_len - 1] = '\0';


