From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Feb 2021 16:44:47 +0000 (GMT)
Subject: main - command defs: add missing commas
Message-ID: <20210222164447.0E795395143A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e836c77a0663649468af613436c210e3ba324b2
Commit:        9e836c77a0663649468af613436c210e3ba324b2
Parent:        12667e9897ad54f5723463b4c864c8259ba0be2a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 22 10:44:01 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 22 10:44:01 2021 -0600

command defs: add missing commas

even though the parser seems to work fine without them
---
 tools/command-lines.in | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2aadd5f40..d6fd0e304 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -318,15 +318,14 @@ OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
 
-OO_LVCONVERT_THIN: --discards Discards --errorwhenfull Bool
+OO_LVCONVERT_THIN: --discards Discards, --errorwhenfull Bool
 
 OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool
 
-OO_LVCONVERT_VDO: --metadataprofile String --readahead Readahead,
---compression Bool, --deduplication Bool
---zero Bool
+OO_LVCONVERT_VDO: --metadataprofile String, --readahead Readahead,
+--compression Bool, --deduplication Bool, --zero Bool
 
 OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
 
@@ -615,8 +614,7 @@ RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 
 lvconvert --vdopool LV_linear_striped_raid_cache
-OO: --type vdo-pool, OO_LVCONVERT_VDO, OO_LVCONVERT
---name LV_new, --virtualsize SizeMB,
+OO: --type vdo-pool, OO_LVCONVERT_VDO, OO_LVCONVERT, --name LV_new, --virtualsize SizeMB,
 ID: lvconvert_to_vdopool_param
 DESC: Convert LV to type vdopool.
 RULE: all and lv_is_visible


