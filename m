From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Nov 2012 11:17:24 +0000 (UTC)
Subject: master - thin: support configurable thin pool defaults
Message-ID: <20121126111724.56F04A0DA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ef98310187a7b287255cacd4b56160e48100d03
Commit:        1ef98310187a7b287255cacd4b56160e48100d03
Parent:        953080e4fc271ad200736f3584f41e24dfe063ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 26 11:20:13 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 26 12:16:47 2012 +0100

thin: support configurable thin pool defaults

Configurable settings for thin pool create
if they are not specified on command line.

New supported lvm.conf options are:
  allocation/thin_pool_chunk_size
  allocation/thin_pool_discards
  allocation/thin_pool_zero
---
 WHATS_NEW             |    1 +
 doc/example.conf.in   |   17 +++++++++++++++++
 lib/config/defaults.h |    3 +++
 lib/thin/thin.c       |   11 ++++++++---
 tools/toollib.c       |   48 +++++++++++++++++++++++++++++++++++-------------
 5 files changed, 64 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 068f453..85fcd3e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lvm.conf thin pool defs thin_pool_{chunk_size|discards|zero}.
   Support discards for non-power-of-2 thin pool chunks.
   Automatically restore MISSING PVs with no MDAs.
   When no '-i' argument is given for RAID10, default to 2 stripes.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 7f94223..1a3ee1b 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -232,6 +232,23 @@ allocation {
     # Set to 1 to guarantee that thin pool metadata will always
     # be placed on different PVs from the pool data.
     thin_pool_metadata_require_separate_pvs = 0
+
+    # Specify the minimal chunk size (in KB) for thin pool volumes.
+    # Use of the larger chunk size may improve perfomance for plain
+    # thin volumes, however using them for snapshot volumes is less efficient,
+    # as it consumes more space and takes extra time for copying.
+    # When unset, lvm tries to estimate chunk size starting from 64KB
+    # Supported values are in range from 64 to 1048576.
+    # thin_pool_chunk_size = 64
+
+    # Specify discards behavior of the thin pool volume.
+    # Select one of  "ignore", "nopassdown", "passdown"
+    # thin_pool_discards = "passdown"
+
+    # Set to 0, to disable zeroing of thin pool data chunks before their
+    # first use.
+    # N.B. zeroing larger thin pool chunk size degrades performance.
+    # thin_pool_zero = 1
 }
 
 # This section that allows you to configure the nature of the
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9730a2d..348fa75 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -69,6 +69,9 @@
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)	/* KB */
+#define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
+#define DEFAULT_THIN_POOL_DISCARDS "passdown"
+#define DEFAULT_THIN_POOL_ZERO 1
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 693b8b6..f6ac437 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -282,10 +282,15 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		return_0;
 
 	if (attr & THIN_FEATURE_DISCARDS) {
+		/* Use ignore for discards ignore or non-power-of-2 chunk_size and <1.5 target */
 		/* FIXME: Check whether underlying dev supports discards */
-		if (!dm_tree_node_set_thin_pool_discard(node,
-							seg->discards == THIN_DISCARDS_IGNORE,
-							seg->discards == THIN_DISCARDS_NO_PASSDOWN))
+		if (((!(attr & THIN_FEATURE_DISCARDS_NON_POWER_2) &&
+		      (seg->chunk_size & (seg->chunk_size - 1))) ||
+		     (seg->discards == THIN_DISCARDS_IGNORE)) &&
+		    !dm_tree_node_set_thin_pool_discard(node, 1, 0))
+			return_0;
+		else if (!dm_tree_node_set_thin_pool_discard(node, 0,
+							     (seg->discards == THIN_DISCARDS_NO_PASSDOWN)))
 			return_0;
 	} else if (seg->discards != THIN_DISCARDS_IGNORE)
 		log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "
diff --git a/tools/toollib.c b/tools/toollib.c
index ba1ba94..4c9a43d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1528,20 +1528,41 @@ int get_pool_params(struct cmd_context *cmd,
 		    uint64_t *pool_metadata_size,
 		    int *zero)
 {
-	if (arg_count(cmd, zero_ARG))
-		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
-	else
-		*zero = 1; /* TODO: Make default configurable */
-
-	*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG,
-						     THIN_DISCARDS_PASSDOWN);
+	const char *dstr;
 
-	if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Negative chunk size is invalid.");
-		return 0;
+	if (arg_count(cmd, zero_ARG)) {
+		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+		log_very_verbose("Setting pool zeroing: %u", *zero);
+	} else
+		*zero = find_config_tree_int(cmd,
+					     "allocation/thin_pool_zero",
+					     DEFAULT_THIN_POOL_ZERO);
+
+	if (arg_count(cmd, discards_ARG)) {
+		*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
+		log_very_verbose("Setting pool discards: %s",
+				 get_pool_discards_name(*discards));
+	} else {
+		dstr = find_config_tree_str(cmd,
+					    "allocation/thin_pool_discards",
+					    DEFAULT_THIN_POOL_DISCARDS);
+		if (!get_pool_discards(dstr, discards))
+			return_0;
 	}
-	*chunk_size = arg_uint_value(cmd, chunksize_ARG,
-				     DM_THIN_MIN_DATA_BLOCK_SIZE);
+
+	if (arg_count(cmd, chunksize_ARG)) {
+		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Negative chunk size is invalid.");
+			return 0;
+		}
+		*chunk_size = arg_uint_value(cmd, chunksize_ARG,
+					     DM_THIN_MIN_DATA_BLOCK_SIZE);
+		log_very_verbose("Setting pool chunk size: %s",
+				 display_size(cmd, *chunk_size));
+	} else
+		*chunk_size = find_config_tree_int(cmd,
+						   "allocation/thin_pool_chunk_size",
+						   DEFAULT_THIN_POOL_CHUNK_SIZE) * 2;
 
 	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
@@ -1619,7 +1640,8 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr,
 			else if (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
 				*chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
 
-			log_verbose("Setting chunk size %uKiB.", *chunk_size / 2);
+			log_verbose("Setting chunk size %s.",
+				    display_size(cmd, *chunk_size));
 		} else if (*chunk_size < estimate_chunk_size) {
 			/* Suggest bigger chunk size */
 			log_warn("WARNING: Chunk size is smaller then suggested minimum size %s.",


