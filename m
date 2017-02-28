From: David Teigland <teigland@sourceware.org>
Date: Tue, 28 Feb 2017 14:49:28 -0500
Subject: master - commands: include lvconvert cache options as group
Message-ID: <201702281949.v1SJnSSl017499@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21456dcf7fc062518202f133ad27594eda4278fb
Commit:        21456dcf7fc062518202f133ad27594eda4278fb
Parent:        89661981e829d2cb228e3db6f8127d14526ea025
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 28 13:47:46 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 28 13:47:46 2017 -0600

commands: include lvconvert cache options as group

---
 tools/command-lines.in |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 26c2deb..1727bbb 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -310,6 +310,9 @@ OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB
 
+OO_LVCONVERT_CACHE: --cachemode CacheMode, --cachepolicy String,
+--cachesettings String, --zero Bool
+
 OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
 
 ---
@@ -434,16 +437,14 @@ RULE: all not lv_is_locked
 ---
 
 lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool
-OO: --cache, --cachemode CacheMode, --cachepolicy String,
---cachesettings String, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
 DESC: Convert LV to type cache.
 RULE: all and lv_is_visible
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
-OO: --type cache, --cachemode CacheMode, --cachepolicy String,
---cachesettings String, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
 DESC: Convert LV to type cache (variant, infers --type cache).
 FLAGS: SECONDARY_SYNTAX
@@ -494,8 +495,7 @@ FLAGS: PREVIOUS_SYNTAX
 ---
 
 lvconvert --type cache-pool LV_linear_striped_raid
-OO: OO_LVCONVERT_POOL, OO_LVCONVERT,
---cachemode CacheMode, --cachepolicy String, --cachesettings String
+OO: OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_cachepool
 DESC: Convert LV to type cache-pool.
@@ -523,8 +523,7 @@ DESC: Convert LV to type cache-pool.
 # of creating a pool or swapping metadata should be used.
 
 lvconvert --cachepool LV_linear_striped_raid_cachepool
-OO: --type cache-pool, OO_LVCONVERT_POOL, OO_LVCONVERT,
---cachemode CacheMode, --cachepolicy String, --cachesettings String
+OO: --type cache-pool, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_cachepool_or_swap_metadata
 DESC: Convert LV to type cache-pool (variant, use --type cache-pool).


