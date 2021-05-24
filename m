From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 May 2021 21:09:54 +0000 (GMT)
Subject: main - enable command syntax for thin and writecache
Message-ID: <20210524210954.7F6123857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a65f8e0a62b9ab3c2fc909a63abfa0e933619a8c
Commit:        a65f8e0a62b9ab3c2fc909a63abfa0e933619a8c
Parent:        102294f9788f243509f1001a60924d6920fd9092
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 19 14:36:40 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 24 16:09:35 2021 -0500

enable command syntax for thin and writecache

converting an LV with a writecache to thin pool data in
addition to previous attaching writecache to thin pool data
---
 tools/command-lines.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1107c1e02..67c37ffd0 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -534,7 +534,7 @@ RULE: all and lv_is_visible
 
 ---
 
-lvconvert --type thin-pool LV_linear_striped_raid_cache_error_zero
+lvconvert --type thin-pool LV_linear_striped_raid_cache_writecache_error_zero
 OO: --stripes_long Number, --stripesize SizeKB,
 OO_LVCONVERT_THINPOOL, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
@@ -566,7 +566,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 # This command syntax is deprecated, and the primary forms
 # of creating a pool or swapping metadata should be used.
 
-lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
+lvconvert --thinpool LV_linear_striped_raid_cache_writecache_thinpool
 OO: --stripes_long Number, --stripesize SizeKB,
 OO_LVCONVERT_THINPOOL, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...


