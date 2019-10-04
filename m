From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:28 -0400
Subject: master - vdo: field update
Message-ID: <201910041533.x94FXSgr031059@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ca9be034f451bc9a87b36dce4f9979db5a67efd
Commit:        7ca9be034f451bc9a87b36dce4f9979db5a67efd
Parent:        cf8aee096f2064fb8d8421f73807ad98746bc7c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 30 15:29:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: field update

---
 lib/report/columns.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 827a157..6f0f638 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -90,12 +90,12 @@ FIELD(LVS, lv, STR, "Convert", lvid, 0, convertlv, convert_lv, "For lvconvert, N
 FIELD(LVS, lv, STR, "Convert UUID", lvid, 38, convertlvuuid, convert_lv_uuid, "For lvconvert, UUID of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 0, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Log UUID", lvid, 38, loglvuuid, mirror_log_uuid, "For mirrors, the UUID of the LV holding the synchronisation log.", 0)
-FIELD(LVS, lv, STR, "Data", lvid, 0, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
-FIELD(LVS, lv, STR, "Data UUID", lvid, 38, datalvuuid, data_lv_uuid, "For thin and cache pools, the UUID of the LV holding the associated data.", 0)
-FIELD(LVS, lv, STR, "Meta", lvid, 0, metadatalv, metadata_lv, "For thin and cache pools, the LV holding the associated metadata.", 0)
-FIELD(LVS, lv, STR, "Meta UUID", lvid, 38, metadatalvuuid, metadata_lv_uuid, "For thin and cache pools, the UUID of the LV holding the associated metadata.", 0)
-FIELD(LVS, lv, STR, "Pool", lvid, 0, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
-FIELD(LVS, lv, STR, "Pool UUID", lvid, 38, poollvuuid, pool_lv_uuid, "For thin volumes, the UUID of the thin pool LV for this volume.", 0)
+FIELD(LVS, lv, STR, "Data", lvid, 0, datalv, data_lv, "For cache/thin/vdo pools, the LV holding the associated data.", 0)
+FIELD(LVS, lv, STR, "Data UUID", lvid, 38, datalvuuid, data_lv_uuid, "For cache/thin/vdo pools, the UUID of the LV holding the associated data.", 0)
+FIELD(LVS, lv, STR, "Meta", lvid, 0, metadatalv, metadata_lv, "For cache/thin pools, the LV holding the associated metadata.", 0)
+FIELD(LVS, lv, STR, "Meta UUID", lvid, 38, metadatalvuuid, metadata_lv_uuid, "For cache/thin pools, the UUID of the LV holding the associated metadata.", 0)
+FIELD(LVS, lv, STR, "Pool", lvid, 0, poollv, pool_lv, "For cache/thin/vdo volumes, the cache/thin/vdo pool LV for this volume.", 0)
+FIELD(LVS, lv, STR, "Pool UUID", lvid, 38, poollvuuid, pool_lv_uuid, "For cache/thin/vdo volumes, the UUID of the cache/thin/vdo pool LV for this volume.", 0)
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 0, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 0, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
 FIELD(LVS, lv, STR, "LLockArgs", lvid, 0, lvlockargs, lv_lockargs, "Lock args of the LV used by lvmlockd.", 0)


