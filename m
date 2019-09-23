From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Sep 2019 15:22:08 -0400
Subject: master - lvconvert: allow --cache shortcut for --type cache with cachevol
Message-ID: <201909231922.x8NJM8IM026228@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fe4c30e7a29017e11de867b7f0d65524f283c1a
Commit:        4fe4c30e7a29017e11de867b7f0d65524f283c1a
Parent:        a353bfdd9f5f612967e514240b8c4cb06d924a19
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 23 11:07:12 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 23 14:21:09 2019 -0500

lvconvert: allow --cache shortcut for --type cache with cachevol

---
 tools/command-lines.in |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 65221c0..7be4715 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -482,6 +482,14 @@ ID: lvconvert_to_cache_with_cachevol
 DESC: Attach a cache to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
 
+# alternate form of lvconvert --type cache
+lvconvert --cache --cachevol LV LV_linear_striped_raid_thinpool
+OO: OO_LVCONVERT_CACHE, OO_LVCONVERT, --poolmetadatasize SizeMB, --chunksize SizeKB
+ID: lvconvert_to_cache_with_cachevol
+DESC: Attach a cache to an LV, converts the LV to type cache.
+RULE: all and lv_is_visible
+FLAGS: SECONDARY_SYNTAX
+
 ---
 
 lvconvert --type thin-pool LV_linear_striped_raid_cache


