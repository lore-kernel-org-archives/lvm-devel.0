From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:27 -0400
Subject: master - thin: restore usability of thin for external origin
Message-ID: <201804201101.w3KB1RL6031126@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7d077b89b71fb2ddd9e87526b5675aadf38dfba
Commit:        a7d077b89b71fb2ddd9e87526b5675aadf38dfba
Parent:        ace97c9f9cdc6f0bfd33ae465404169a33953c1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 18:55:09 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:06:03 2018 +0200

thin: restore usability of thin for external origin

With command definition it's been lost support for thin LV being
an external origin for another thinLV.
---
 WHATS_NEW              |    1 +
 tools/command-lines.in |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9f078b5..192c5c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Restore usability of thin LV to be again external origin for another thin.
   Keep systemd vars on change event in 69-dm-lvm-metad.rules for systemd reload.
   Write systemd and non-systemd rule in 69-dm-lvm-metad.rules, GOTO active one.
   Add test for activation/volume_list (Sub)LV remnants.
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2a6882e..e555e95 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -421,7 +421,7 @@ FLAGS: SECONDARY_SYNTAX
 # lvconvert utilities for creating/maintaining thin and cache objects.
 # Create a new command set for these and migrate them out of lvconvert?
 
-lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache
+lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache_thin
 OO: --thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
@@ -430,7 +430,7 @@ RULE: all not lv_is_locked
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type thin
-lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
+lvconvert --thin --thinpool LV LV_linear_striped_raid_cache_thin
 OO: --type thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin


