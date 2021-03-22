From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:20 +0000 (GMT)
Subject: dev-next - pool: allow data on zero and error segtypes
Message-ID: <20210322153920.D8D6F385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c3774c7a834bd0ad0dcf356f694e123d8955d9d
Commit:        1c3774c7a834bd0ad0dcf356f694e123d8955d9d
Parent:        7a9efc5fae713a09cc1d1238a19a1cac555fb364
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 18:26:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:57:45 2021 +0100

pool: allow data on zero and error segtypes

Renables usage of --type zero and --type error LVs to serve as
backend for _tdata device. Clearly not very useful in practice,
as it can't store any real data, but usable for some testing
and some sort of perfomance checking.

  lvcreate --type zero -L1T -n pool vg
  lvconvert --thinpool vg/pool

Will create a thin-pool with zero device backend.
---
 tools/command-lines.in | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 621731174..528811f52 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -435,7 +435,7 @@ FLAGS: SECONDARY_SYNTAX
 # lvconvert utilities for creating/maintaining thin and cache objects.
 # Create a new command set for these and migrate them out of lvconvert?
 
-lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache_thin
+lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache_thin_error_zero
 OO: --thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
@@ -444,7 +444,7 @@ RULE: all not lv_is_locked lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type thin
-lvconvert --thin --thinpool LV LV_linear_striped_raid_cache_thin
+lvconvert --thin --thinpool LV LV_linear_striped_raid_cache_thin_error_zero
 OO: --type thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin
@@ -517,7 +517,7 @@ RULE: all and lv_is_visible
 
 ---
 
-lvconvert --type thin-pool LV_linear_striped_raid_cache
+lvconvert --type thin-pool LV_linear_striped_raid_cache_error_zero
 OO: --stripes_long Number, --stripesize SizeKB,
 OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
@@ -593,7 +593,7 @@ RULE: all not lv_is_raid_with_integrity
 # This command syntax is deprecated, and the primary forms
 # of creating a pool or swapping metadata should be used.
 
-lvconvert --cachepool LV_linear_striped_raid_cachepool
+lvconvert --cachepool LV_linear_striped_raid_cachepool_error_zero
 OO: --type cache-pool, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_cachepool_or_swap_metadata


