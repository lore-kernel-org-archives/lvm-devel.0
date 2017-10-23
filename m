From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Oct 2017 06:07:13 -0400
Subject: master - lvconvert: preserve names of converted LV
Message-ID: <201710231007.v9NA7DeI003912@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de58df390b6bd3f46841fdacb9a75defccf9f3e2
Commit:        de58df390b6bd3f46841fdacb9a75defccf9f3e2
Parent:        d6f4563103a626bbe6a9e768a090233541ecd24c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 23 10:56:44 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 23 11:58:27 2017 +0200

lvconvert: preserve names of converted LV

When prompting and warning for conversion, remember initial LV names,
so after conversion is finished, correct original names are printed.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8ee5b0c..2644d37 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Show original converted names when lvconverting LV to pool volume.
   Move lib code used only by liblvm into metadata-liblvm.c.
   Distinguish between device not found and excluded by filter.
   Monitor external origin LVs.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 28909dd..02c649c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2864,6 +2864,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	const char *pool_name;                      /* name of original lv arg */
 	char meta_name[NAME_LEN];                   /* generated sub lv name */
 	char data_name[NAME_LEN];                   /* generated sub lv name */
+	char converted_names[3*NAME_LEN];	    /* preserve names of converted lv */
 	struct segment_type *pool_segtype;          /* thinpool or cachepool */
 	struct lv_segment *seg;
 	unsigned int target_attr = ~0;
@@ -3052,14 +3053,16 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	log_verbose("Pool metadata extents %u chunk_size %u", meta_extents, chunk_size);
 
+	(void) dm_snprintf(converted_names, sizeof(converted_names), "%s%s%s",
+			   display_lvname(lv),
+			   metadata_lv ? " and " : "",
+			   metadata_lv ? display_lvname(metadata_lv) : "");
+
 	/*
 	 * Verify that user wants to use these LVs.
 	 */
-
-	log_warn("WARNING: Converting logical volume %s%s%s to %s pool's data%s %s metadata wiping.",
-		 display_lvname(lv),
-		 metadata_lv ? " and " : "",
-		 metadata_lv ? display_lvname(metadata_lv) : "",
+	log_warn("WARNING: Converting %s to %s pool's data%s %s metadata wiping.",
+		 converted_names,
 		 to_cachepool ? "cache" : "thin",
 		 metadata_lv ? " and metadata volumes" : " volume",
 		 zero_metadata ? "with" : "WITHOUT");
@@ -3070,10 +3073,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		log_warn("WARNING: Using mismatched cache pool metadata MAY DESTROY YOUR DATA!");
 
 	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
-			  display_lvname(lv),
-			  metadata_lv ? " and " : "",
-			  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
+	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",
+			  converted_names) == 'n') {
 		log_error("Conversion aborted.");
 		goto bad;
 	}
@@ -3289,8 +3290,7 @@ out:
 
 	if (r)
 		log_print_unless_silent("Converted %s to %s pool.",
-					display_lvname(lv),
-					to_cachepool ? "cache" : "thin");
+					converted_names, to_cachepool ? "cache" : "thin");
 
 	/*
 	 * Unlock and free the locks from existing LVs that became pool data


