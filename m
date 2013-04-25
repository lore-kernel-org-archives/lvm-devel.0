From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Apr 2013 15:34:31 +0000 (UTC)
Subject: master - report: show active state of LV
Message-ID: <20130425153431.4DF6D36BD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d004b51274b2d7638673c4985c0c298d253ef0d
Commit:        8d004b51274b2d7638673c4985c0c298d253ef0d
Parent:        8b18ab76d27f40094f281d5695a6bb82b65e1976
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 25 12:12:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

report: show active state of LV

For non clustered VG - show  "active"/""

For clustered VG its more complex:

"local exclusive"
"remote exclusive"
"locally"
"remotely"
---
 WHATS_NEW               |    1 +
 lib/metadata/lv.c       |   19 +++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   14 ++++++++++++++
 6 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a625dba..bad183c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add "active" LV reporting field to show activation state.
   Add "monitor" segment reporting field to show dmevent monitoring status.
   Document lvextend --use-policies option in man.
   Fix creation and removal of clustered snapshot.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e515e02..3dbdb38 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -703,3 +703,22 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	return dm_pool_strdup(mem, lv->hostname ? : "");
 }
+
+char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	const char *s;
+
+	if (!lv_is_active(lv))
+		s = ""; /* not active */
+	else if (!vg_is_clustered(lv->vg))
+		s = "active";
+	else if (lv_is_active_exclusive(lv))
+		/* exclusive cluster activation */
+		s = lv_is_active_exclusive_locally(lv) ?
+			"local exclusive" : "remote exclusive";
+	else /* locally active */
+		s = lv_is_active_but_not_locally(lv) ?
+		     "remotely" : "locally";
+
+	return dm_pool_strdup(mem, s);
+}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 7652cd4..9450f8d 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -85,4 +85,5 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
 const char *lv_layer(const struct logical_volume *lv);
+char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 #endif /* _LVM_LV_H */
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 07c9b7b..e73d20d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -82,6 +82,7 @@ FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, m
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
+FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "WBehind", lvid, 7, write_behind, writebehind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 6f0d980..03ebc6f 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -247,6 +247,8 @@ GET_LV_STR_PROPERTY_FN(lv_time, lv_time_dup(lv->vg->vgmem, lv))
 #define _lv_time_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_host, lv_host_dup(lv->vg->vgmem, lv))
 #define _lv_host_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_active, lv_active_dup(lv->vg->vgmem, lv))
+#define _lv_active_set _not_implemented_set
 
 /* VG */
 GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
diff --git a/lib/report/report.c b/lib/report/report.c
index 9ef2687..27c9708 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1151,6 +1151,20 @@ static int _lvhost_disp(struct dm_report *rh, struct dm_pool *mem,
 	return 1;
 }
 
+static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	char *repstr;
+
+	if (!(repstr = lv_active_dup(mem, (const struct logical_volume *) data)))
+		return_0;
+
+	dm_report_field_set_value(field, repstr, NULL);
+
+	return 1;
+}
+
 /* Report object types */
 
 /* necessary for displaying something for PVs not belonging to VG */


