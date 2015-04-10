From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 10 Apr 2015 12:55:44 +0000 (UTC)
Subject: master - report: lv_metadata_size, data_lv and metadata_lv also reports properties for cache pools
Message-ID: <20150410125544.A7CD660DAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=394250ef6759243e59de41dd6cfced544c041c76
Commit:        394250ef6759243e59de41dd6cfced544c041c76
Parent:        463fd954bb87a9a565169a134f2d36acb6c7adf3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 10 14:55:28 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 10 14:55:28 2015 +0200

report: lv_metadata_size, data_lv and metadata_lv also reports properties for cache pools

---
 lib/report/columns.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index a957d98..6fde503 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -60,7 +60,7 @@ FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number o
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SIZ, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
 FIELD(LVS, lv, SIZ, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
-FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin pools, the size of the LV that holds the metadata.", 0)
+FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin and cache pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
@@ -77,8 +77,8 @@ FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, raidmaxrecoveryrate, raid_max_recovery_r
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
-FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin pools, the LV holding the associated data.", 0)
-FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin pools, the LV holding the associated metadata.", 0)
+FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin and cache pools, the LV holding the associated data.", 0)
+FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cache pools, the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)


