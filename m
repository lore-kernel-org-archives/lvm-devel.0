From: David Teigland <teigland@sourceware.org>
Date: Tue, 2 Jul 2019 12:03:54 -0400
Subject: master - cache: warn and prompt for writeback with cachevol
Message-ID: <201907021603.x62G3ssb029919@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f938545687accd8f451b1bde806484301e0ae086
Commit:        f938545687accd8f451b1bde806484301e0ae086
Parent:        ba9d152aa5552f2b6d9ea3acf5ae644dc4dd1596
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 2 10:59:40 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 2 11:03:03 2019 -0500

cache: warn and prompt for writeback with cachevol

The cache repair utility does not yet work with a cachevol
(where metadata and data exist on the same LV.)  So, warn
and prompt if writeback is specified with a cachevol.
---
 test/shell/cache-single-options.sh |    2 +-
 tools/lvchange.c                   |    8 ++++++++
 tools/lvconvert.c                  |    8 ++++++++
 3 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index da9cbba..6b71b2f 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -228,7 +228,7 @@ lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 
 lvchange -ay $vg/$lv1
 
-lvchange --cachemode writeback $vg/$lv1
+lvchange -y --cachemode writeback $vg/$lv1
 
 check lv_field $vg/$lv1 cachemode "writeback"
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e7fb57d..c28a7bb 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -635,6 +635,14 @@ static int _lvchange_cache(struct cmd_context *cmd,
 	if (!get_cache_params(cmd, &chunk_size, &format, &mode, &name, &settings))
 		goto_out;
 
+	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv) && (mode == CACHE_MODE_WRITEBACK)) {
+		log_warn("WARNING: repairing a damaged cachevol is not yet possible.");
+		log_warn("WARNING: cache mode writethrough is suggested for safe operation.");
+		if (!arg_count(cmd, yes_ARG) &&
+			yes_no_prompt("Continue using writeback without repair?") == 'n')
+			goto_out;
+	}
+
 	if ((mode != CACHE_MODE_UNSELECTED) &&
 	    (mode != setting_seg->cache_mode) &&
 	    lv_is_cache(lv)) {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 24db8d2..ebc2243 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3401,6 +3401,14 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 	if (!cache_vol_set_params(cmd, cache_lv, lv_fast, poolmetadatasize, chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
 		goto_out;
 
+	if (cache_mode == CACHE_MODE_WRITEBACK) {
+		log_warn("WARNING: repairing a damaged cachevol is not yet possible.");
+		log_warn("WARNING: cache mode writethrough is suggested for safe operation.");
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Continue using writeback without repair?") == 'n')
+			goto_out;
+	}
+
 	/*
 	 * lv/cache_lv keeps the same lockd lock it had before, the lock for
 	 * lv_fast is freed, and lv_corig has no lock.


