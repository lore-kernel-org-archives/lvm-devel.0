From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 03 Aug 2011 09:44:09 -0500
Subject: [PATCH 3 of 5] LVM RAID: New function - lv_raid_percent
In-Reply-To: <1312381844.1169.8.camel@f14.redhat.com>
References: <1312381844.1169.8.camel@f14.redhat.com>
Message-ID: <1312382649.1169.21.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add function 'lv_raid_percent'

'lv_raid_percent' operates exactly the same as 'lv_mirror_percent', so
it is simply a wrapper around that function.

lv_[snapshot|mirror|raid]_percent should be combined - perhaps at the
dev_manager level while retaining distinct lv_*_percent calls.  We will
not be able to combine the snapshot percent function with the other types
for the simple reason that we must account for the "-real" layer.  Perhaps
lv_snapshot_percent will become a wrapper around a more generic function -
its only purpose being to flag that it wants the snapshot %'age and not
an underlying LV's %'age.

Anyway, this simple wrapper will suit RAID's purposes for now.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
@@ -611,6 +611,11 @@ int lv_mirror_percent(struct cmd_context
 	return r;
 }
 
+int lv_raid_percent(const struct logical_volume *lv, percent_t *percent)
+{
+	return lv_mirror_percent(lv->vg->cmd, lv, 0, percent, NULL);
+}
+
 static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct lvinfo info;
Index: LVM2/lib/activate/activate.h
===================================================================
--- LVM2.orig/lib/activate/activate.h
+++ LVM2/lib/activate/activate.h
@@ -93,6 +93,7 @@ int lv_check_transient(struct logical_vo
 int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
+int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
 
 /*
  * Return number of LVs in the VG that are active.




