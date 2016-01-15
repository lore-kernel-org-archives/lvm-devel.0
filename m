From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Jan 2016 13:42:53 +0000 (UTC)
Subject: master - lvm2app: fix lvm2app to return either 0 or 1 for lvm_vg_is_{clustered, exported}
Message-ID: <20160115134253.5F50A60E77@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7559af2334a619bc3dcbf558152841b2695c8616
Commit:        7559af2334a619bc3dcbf558152841b2695c8616
Parent:        1752f5c31e8fc1801cbc694939a16f0eb6695bcd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 15 14:39:43 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 15 14:42:18 2016 +0100

lvm2app: fix lvm2app to return either 0 or 1 for lvm_vg_is_{clustered,exported}

Fix lvm2app to return either 0 or 1 for lvm_vg_is_{clustered,exported},
including internal functions pvseg_is_allocated and vg_is_resizeable
which are not yet exposed in lvm2app but make them consistent with the
rest.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b64f725..7023510 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Fix lvm2app to return either 0 or 1 for lvm_vg_is_{clustered,exported}.
   Add kernel_discards report field to display thin pool discard used in kernel.
   Correct checking of target presence when driver access is disabled.
   Eval poolmetadatasize arg earlier in lvresize.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a118fa8..4f25f7d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -305,7 +305,7 @@ struct pv_segment {
 	uint32_t lv_area;	/* Index to area in LV segment */
 };
 
-#define pvseg_is_allocated(pvseg) ((pvseg)->lvseg)
+#define pvseg_is_allocated(pvseg) ((pvseg)->lvseg ? 1 : 0)
 
 /*
  * Properties of each format instance type.
@@ -1204,9 +1204,9 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
 int vg_flag_write_locked(struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
-#define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
-#define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
-#define vg_is_resizeable(vg) (vg_status((vg)) & RESIZEABLE_VG)
+#define vg_is_clustered(vg) ((vg_status((vg)) & CLUSTERED) ? 1 : 0)
+#define vg_is_exported(vg) ((vg_status((vg)) & EXPORTED_VG) ? 1 : 0)
+#define vg_is_resizeable(vg) ((vg_status((vg)) & RESIZEABLE_VG) ? 1 : 0)
 
 int lv_has_unknown_segments(const struct logical_volume *lv);
 int vg_has_unknown_segments(const struct volume_group *vg);


