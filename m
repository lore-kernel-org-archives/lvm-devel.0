From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:20 +0200
Subject: [PATCH 08/25] Replicator: add report for replicator/ed targets
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <bff2fb3b06589f80cf4a3fe925085dc0961b3920.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Elementary reporting tool for replicator and replicato-dev LVs.
Replicator uses free flag 'q'.
Replicated  'r' for normal, 'R' for unsynchronized replicated LV.
Note: unsychronized status not yet implemented.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/report/columns.h |    2 ++
 lib/report/report.c  |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9eca600..a48210e 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -76,6 +76,8 @@ FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, "convert_lv", "For lvconvert,
 FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, "lv_tags", "Tags, if any.")
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log", "For mirrors, the LV holding the synchronisation log.")
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mapper modules required for this LV.")
+FIELD(LVS, lv, STR, "RImage", lvid, 7, rimage, "rimage", "For replicators, the replicated image of this LV.")
+FIELD(LVS, lv, STR, "Replicator", lvid, 7, replicator, "replicator", "For replicators, the replicator control LV.")
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
diff --git a/lib/report/report.c b/lib/report/report.c
index b3f6544..9a4d99f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -303,6 +303,10 @@ static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 		repstr[0] = 'p';
 	else if (lv->status & CONVERTING)
 		repstr[0] = 'c';
+	else if (lv_is_replicator(lv))
+		repstr[0] = 'q';
+	else if (lv_is_replicated(lv))
+		repstr[0] = (lv->status & REPLICATOR_NOTSYNCED) ? 'R' : 'r';
 	else if (lv->status & VIRTUAL)
 		repstr[0] = 'v';
 	/* Origin takes precedence over Mirror */
@@ -605,6 +609,34 @@ static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 	return 1;
 }
 
+static int _rimage_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_replicated(lv))
+		return _lvname_disp(rh, mem, field, lv->rdevice->lv, private);
+
+	dm_report_field_set_value(field, "", NULL);
+
+	return 1;
+}
+
+static int _replicator_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_replicated(lv))
+		return _lvname_disp(rh, mem, field, lv->rdevice->rsite->replicator, private);
+
+	dm_report_field_set_value(field, "", NULL);
+
+	return 1;
+}
+
 static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
-- 
1.7.2.1


