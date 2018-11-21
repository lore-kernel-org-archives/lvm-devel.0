From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Nov 2018 16:18:56 -0500
Subject: master - writecache: set block_size using --cachesettings
Message-ID: <201811212118.wALLIucH020766@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=229e63b6388ae384fad08dfbf659b360b95753bc
Commit:        229e63b6388ae384fad08dfbf659b360b95753bc
Parent:        9deb1340143f4e036e2531788adc5ad82751cbfd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 21 15:16:23 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 21 15:16:23 2018 -0600

writecache: set block_size using --cachesettings

instead of a separate --writecacheblocksize option.
writecache block_size is not technically a setting,
but it can borrow the option as a special case.
---
 man/lvmcache.7_main    |    2 +-
 tools/args.h           |    3 ---
 tools/command-lines.in |    2 +-
 tools/lvconvert.c      |   35 +++++++++++++++++++++++------------
 4 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 1e2acf4..89a1943 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -117,7 +117,7 @@ attached.
 The dm-writecache block size can be 4096 bytes (the default), or 512
 bytes.  The default 4096 has better performance and should be used except
 when 512 is necessary for compatibility.  The dm-writecache block size is
-specified with --writecacheblocksize 4096b|512b when caching is started.
+specified with --cachesettings block_size=4096|512 when caching is started.
 
 When a file system like xfs already exists on the main LV prior to
 caching, and the file system is using a block size of 512, then the
diff --git a/tools/args.h b/tools/args.h
index 1ceba99..414d7a8 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -812,9 +812,6 @@ arg(withversions_ARG, '\0', "withversions", 0, 0, 0,
     "each configuration node. If the setting is deprecated, also display\n"
     "the version since which it is deprecated.\n")
 
-arg(writecacheblocksize_ARG, '\0', "writecacheblocksize", sizekb_VAL, 0, 0,
-    "The block size to use for cache blocks in writecache.\n")
-
 arg(writebehind_ARG, '\0', "writebehind", number_VAL, 0, 0,
     "The maximum number of outstanding writes that are allowed to\n"
     "devices in a RAID1 LV that is marked write-mostly.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 018153a..b06acec 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -470,7 +470,7 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvconvert --type writecache --cachepool LV LV_linear_striped_raid
-OO: OO_LVCONVERT, --cachesettings String, --writecacheblocksize SizeKB
+OO: OO_LVCONVERT, --cachesettings String
 ID: lvconvert_to_writecache_vol
 DESC: Attach a writecache to an LV, converts the LV to type writecache.
 RULE: all and lv_is_visible
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a207bd9..a29a66b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5271,8 +5271,22 @@ out:
 }
 
 static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
-				       char *key, char *val)
+				       char *key, char *val, uint32_t *block_size_sectors)
 {
+	/* special case: block_size is not a setting but is set with the --cachesettings option */
+	if (!strncmp(key, "block_size", strlen("block_size"))) {
+		uint32_t block_size = 0;
+		if (sscanf(val, "%u", &block_size) != 1)
+			goto_bad;
+		if (block_size == 512)
+			*block_size_sectors = 1;
+		else if (block_size == 4096)
+			*block_size_sectors = 8;
+		else
+			goto_bad;
+		return 1;
+	}
+
 	if (!strncmp(key, "high_watermark", strlen("high_watermark"))) {
 		if (sscanf(val, "%llu", (unsigned long long *)&settings->high_watermark) != 1)
 			goto_bad;
@@ -5352,7 +5366,8 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	return 0;
 }
 
-static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings)
+static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings,
+				    uint32_t *block_size_sectors)
 {
 	struct arg_value_group_list *group;
 	const char *str;
@@ -5388,7 +5403,7 @@ static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_s
 
 			pos += num;
 
-			if (!_get_one_writecache_setting(cmd, settings, key, val))
+			if (!_get_one_writecache_setting(cmd, settings, key, val, block_size_sectors))
 				return_0;
 		}
 	}
@@ -5437,6 +5452,8 @@ static struct logical_volume *_lv_writecache_create(struct cmd_context *cmd,
 	return lv_wcorig;
 }
 
+#define DEFAULT_WRITECACHE_BLOCK_SIZE_SECTORS 8 /* 4K */
+
 static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct processing_handle *handle)
@@ -5469,16 +5486,10 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/* default block size is 4096 bytes (8 sectors) */
-	block_size_sectors = arg_int_value(cmd, writecacheblocksize_ARG, 8);
-	if (block_size_sectors > 8) {
-		log_error("Max writecache block size is 4096 bytes.");
-		return 0;
-	}
-
 	memset(&settings, 0, sizeof(settings));
+	block_size_sectors = DEFAULT_WRITECACHE_BLOCK_SIZE_SECTORS;
 
-	if (!_get_writecache_settings(cmd, &settings)) {
+	if (!_get_writecache_settings(cmd, &settings, &block_size_sectors)) {
 		log_error("Invalid writecache settings.");
 		return 0;
 	}
@@ -5498,7 +5509,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 * an existing file system on lv may become unmountable with the
 	 * writecache attached because of the changing sector size.  If this
 	 * happens, then use --splitcache, and reattach the writecache using a
-	 * --writecacheblocksize value matching the sector size of lv.
+	 * writecache block_size value matching the sector size of lv.
 	 */
 
 	if (!_writecache_zero(cmd, lv_fast)) {


