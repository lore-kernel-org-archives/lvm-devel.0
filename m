From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Feb 2016 11:14:32 +0000 (UTC)
Subject: master - report: report -1, not 'unkown' for lv_{snapshot_invalid, merge_failed} with --binary
Message-ID: <20160218111432.C3D0260B69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc19a16fc7d952550849b1f6359ed0515515f0aa
Commit:        bc19a16fc7d952550849b1f6359ed0515515f0aa
Parent:        e5fc48411a5e872eb7c34dff51aa7e0910812119
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 18 12:10:00 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 18 12:10:00 2016 +0100

report: report -1, not 'unkown' for lv_{snapshot_invalid,merge_failed} with --binary

State:
$ lvs -o lv_name,lv_active_locally,lv_snapshot_invalid,lv_merge_failed vg/lvol0
  LV    ActLocal       SnapInvalid     MergeFailed
  lvol0 active locally         unknown         unknown

Now with using --binary switch.

Before this patch (lv_snapshot_invalid and lv_merge_failed not switched into numeric value
where -1 represents 'unknown' value)
$ lvs -o lv_name,lv_active_locally,lv_snapshot_invalid,lv_merge_failed vg/lvol0 --binary
  LV    ActLocal   SnapInvalid     MergeFailed
  lvol0          1         unknown         unknown

With this patch applied:
$ lvs -o lv_name,lv_active_locally,lv_snapshot_invalid,lv_merge_failed vg/lvol0 --binary
  LV    ActLocal   SnapInvalid     MergeFailed
  lvol0          1              -1              -1
---
 WHATS_NEW           |    1 +
 lib/report/report.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a4474cd..bf3fc07 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.143 -
 =====================================
+  Report -1, not 'unkown' for lv_{snapshot_invalid,merge_failed} with --binary.
   Add configure --enable-dbus-service for an LVM D-Bus service.
   Replace configure --enable-python_bindings with python2 and python3 versions.
   If PV belongs to some VG and metadata missing, skip it if system ID is used.
diff --git a/lib/report/report.c b/lib/report/report.c
index 123b9f0..542cbc4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3194,7 +3194,7 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 	int merge_failed;
 
 	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &snap_percent))
-		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
+		return _binary_undef_disp(rh, mem, field, private);
 
 	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
 	return _binary_disp(rh, mem, field, merge_failed, GET_FIRST_RESERVED_NAME(lv_merge_failed_y), private);
@@ -3209,7 +3209,7 @@ static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 	int snap_invalid;
 
 	if (!lv_is_cow(lv))
-		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
+		return _binary_undef_disp(rh, mem, field, private);
 
 	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
 	return _binary_disp(rh, mem, field, snap_invalid, GET_FIRST_RESERVED_NAME(lv_snapshot_invalid_y), private);


