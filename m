From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 11 Jul 2014 09:21:37 +0000 (UTC)
Subject: master - report: display 'unknown' value for active/active_locally/active_remotely/active_exclusively if info bypassed
Message-ID: <20140711092137.5174160F9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9ae21798e1fa94e56c0f07ece1527377cbf1623
Commit:        c9ae21798e1fa94e56c0f07ece1527377cbf1623
Parent:        52af0dfbc0ebc442d3f1163e944e9ad88d05d46e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 11 11:15:06 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 11 11:15:06 2014 +0200

report: display 'unknown' value for active/active_locally/active_remotely/active_exclusively if info bypassed

Before the patch:

$ lvs -o name,active vg/lvol1 --driverloaded n
  WARNING: Activation disabled. No device-mapper interaction will beattempted.
  LV    Active
  lvol1 active

With this patch applied:
$ lvs -o name,active vg/lvol1 --driverloaded n
  WARNING: Activation disabled. No device-mapper interaction will be attempted.
  LV    Active
  lvol1 unknown

The same for active_{locally,remotely,exclusively} fields.
Also, rename headings for these fields (ActLocal/ActRemote/ActExcl).
---
 lib/metadata/lv.c    |    7 ++++++-
 lib/report/columns.h |    6 +++---
 lib/report/report.c  |    9 +++++++++
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 1ede9d6..d8fd320 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -910,6 +910,11 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	const char *s;
 
+	if (!activation()) {
+		s = "unknown";
+		goto out;
+	}
+
 	if (vg_is_clustered(lv->vg)) {
 		//const struct logical_volume *lvo = lv;
 		lv = lv_lock_holder(lv);
@@ -927,7 +932,7 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else /* locally active */
 		s = lv_is_active_but_not_locally(lv) ?
 			"remotely" : "locally";
-
+out:
 	return dm_pool_strdup(mem, s);
 }
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index dd5aa9e..af39008 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -53,9 +53,9 @@ FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kerne
 FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
-FIELD(LVS, lv, BIN, "ActiveLoc", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
-FIELD(LVS, lv, BIN, "ActiveRem", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
-FIELD(LVS, lv, BIN, "ActiveExcl", lvid, 10, lvactiveexclusively, lv_active_exclusively, "Set if the LV is active exclusively.", 0)
+FIELD(LVS, lv, BIN, "ActLocal", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
+FIELD(LVS, lv, BIN, "ActRemote", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
+FIELD(LVS, lv, BIN, "ActExcl", lvid, 10, lvactiveexclusively, lv_active_exclusively, "Set if the LV is active exclusively.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SIZ, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 061e39e..e9f379a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1454,6 +1454,9 @@ static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	int active_locally;
 
+	if (!activation())
+		return _binary_undef_disp(rh, mem, field, private);
+
 	if (vg_is_clustered(lv->vg)) {
 		lv = lv_lock_holder(lv);
 		active_locally = lv_is_active_locally(lv);
@@ -1470,6 +1473,9 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	int active_remotely;
 
+	if (!activation())
+		return _binary_undef_disp(rh, mem, field, private);
+
 	if (vg_is_clustered(lv->vg)) {
 		lv = lv_lock_holder(lv);
 		active_remotely = lv_is_active_but_not_locally(lv);
@@ -1486,6 +1492,9 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	int active_exclusively;
 
+	if (!activation())
+		return _binary_undef_disp(rh, mem, field, private);
+
 	if (vg_is_clustered(lv->vg)) {
 		lv = lv_lock_holder(lv);
 		active_exclusively = lv_is_active_exclusive(lv);


