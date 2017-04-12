From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Apr 2017 14:35:20 -0400
Subject: master - commands: add rule for lvconvert commands that create pools
Message-ID: <201704121835.v3CIZKBU004617@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61cfe2d55b145e16f841cc1e23a3939b7fd91d6d
Commit:        61cfe2d55b145e16f841cc1e23a3939b7fd91d6d
Parent:        19e6c338d32a081a94fb210785f0443406d2ff66
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 12 13:33:40 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 12 13:33:40 2017 -0500

commands: add rule for lvconvert commands that create pools

For an lvconvert command that creates a thin pool or cache pool,
--poolmetadata cannot be used with --readahead, --stripes or --stripesize.
---
 tools/command-lines.in |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 5a3b520..2d9e48e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -427,6 +427,7 @@ ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type thin
 lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
@@ -437,6 +438,7 @@ DESC: (infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
 
@@ -445,6 +447,7 @@ OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
 DESC: Convert LV to type cache.
 RULE: all and lv_is_visible
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
@@ -452,6 +455,7 @@ OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
 DESC: Convert LV to type cache (infers \\-\\-type cache).
 RULE: all and lv_is_visible
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -464,6 +468,7 @@ ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # This command syntax has two different meanings depending on
 # whether the LV pos arg is already a thin pool or not.
@@ -496,6 +501,7 @@ DESC: Convert LV to type thin-pool (variant, use \\-\\-type thin-pool).
 DESC: Swap metadata LV in a thin pool (variant, use \\-\\-swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
 
@@ -504,6 +510,7 @@ OO: OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_cachepool
 DESC: Convert LV to type cache-pool.
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # This command syntax has two different meanings depending on
 # whether the LV pos arg is already a cache pool or not.
@@ -535,6 +542,7 @@ DESC: Convert LV to type cache-pool (variant, use \\-\\-type cache-pool).
 DESC: Swap metadata LV in a cache pool (variant, use \\-\\-swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
+RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
 


