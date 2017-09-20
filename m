From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Sep 2017 09:14:44 -0400
Subject: master - lvconvert: repair supports poometadatespare switch
Message-ID: <201709201314.v8KDEihd009449@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aeb4f2bf3d25927e6cac2e37842498b207fefd1c
Commit:        aeb4f2bf3d25927e6cac2e37842498b207fefd1c
Parent:        03bcd29481e879eb890278997e7f7214757de952
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 13 11:48:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 20 15:14:16 2017 +0200

lvconvert: repair supports poometadatespare switch

Enable handling of  --poolmetadataspare so if user can prevent
creation of _pmspare volume during --repair operation (just
like during actual lvcreate or lvconvert) for pool volumes.
---
 WHATS_NEW              |    1 +
 tools/command-lines.in |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8e8ed2c..e76214d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.175 - 
 ======================================
+  lvconvert --repair respects --poolmetadataspare option.
 
 Version 2.02.174 - 13th September 2017
 ======================================
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2f4e48f..e915483 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -664,12 +664,13 @@ FLAGS: SECONDARY_SYNTAX
 # and the LV type is known.
 
 lvconvert --repair LV_raid_mirror_thinpool
-OO: --usepolicies, --interval Number, OO_LVCONVERT
+OO: --usepolicies, --interval Number, --poolmetadataspare Bool, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_repair_pvs_or_thinpool
 DESC: Replace failed PVs in a raid or mirror LV.
 DESC: Repair a thin pool.
 RULE: all not lv_is_locked lv_is_pvmove
+RULE: --poolmetadataspare Bool and LV_cache LV_cachepool LV_thinpool
 
 lvconvert --replace PV LV_raid
 OO: OO_LVCONVERT


