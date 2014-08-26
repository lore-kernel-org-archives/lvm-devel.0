From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 26 Aug 2014 15:41:56 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140826154156.67ACB6036A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b8d21f8733d800dd672bcc629b20d8585d2021a
Commit:        8b8d21f8733d800dd672bcc629b20d8585d2021a
Parent:        50babdf123349f9efdcf91f63d11bfece98ee6ab
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 26 16:34:14 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 26 16:34:14 2014 +0100

pre-release

---
 VERSION                 |    2 +-
 VERSION_DM              |    2 +-
 WHATS_NEW               |    5 +++--
 WHATS_NEW_DM            |    5 +++--
 lib/metadata/lv_manip.c |    4 ++--
 lib/report/columns.h    |    2 +-
 man/lvm.8.in            |    5 ++---
 tools/lvconvert.c       |    2 +-
 8 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/VERSION b/VERSION
index 81e874b..86bdbb0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.110(2)-git (2014-08-05)
+2.02.110(2)-git (2014-08-26)
diff --git a/VERSION_DM b/VERSION_DM
index f2b3ee8..27fe4c7 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.89-git (2014-08-05)
+1.02.89-git (2014-08-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2e27043..1d82ed5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,10 @@
-Version 2.02.110 -
-==================================
+Version 2.02.110 - 26th August 2014
+===================================
   Fix manipulation with thin-pools which are excluded via volume_list.
   Support lv/vgremove -ff to remove thin vols from broken/inactive thin pools.
   Fix typo breaking configure --with-lvm1=shared.
   Modify lvresize code to handle raid/mirrors and physical extents.
+  Don't allow pvcreate to proceed if scanning or filtering fails.
   Cleanly error when creating RAID with stripe size < PAGE_SIZE.
   Print name of LV which on activation triggers delayed snapshot merge.
   Add lv_layout and lv_role LV reporting fields.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 484cb7e..83119f6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.89 -
-=================================
+Version 1.02.89 - 26th August 2014
+==================================
+  Improve libdevmapper-event select() error handling.
   Add extra check for matching transation_id after message submitting.
   Add dm_report_field_string_list_unsorted for str. list report without sorting.
   Support --deferred with dmsetup remove to defer removal of open devices.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3d91856..a5614f6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6570,8 +6570,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			 *        volumes as well.  Avoiding doing that now
 			 *        only to minimize the change.
 			 */
-			log_error("The extent size in volume group %s is too"
-				  " small to support striped RAID volumes.",
+			log_error("The extent size in volume group %s is too "
+				  "small to support striped RAID volumes.",
 				  vg->name);
 			return NULL;
 		}
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 78f5832..796ac4e 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -148,7 +148,7 @@ FIELD(VGS, vg, SIZ, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata a
 FIELD(VGS, vg, SIZ, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
 
-FIELD(SEGS, seg, STR, "SegType", list, 4, segtype, segtype, "Type of LV segment.", 0)
+FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 6, size32, stripesize, "For stripes, amount of data placed on one device before switching to the next.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 6, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 069194c..c6f72a3 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -345,9 +345,8 @@ The valid characters for VG and LV names are:
 VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
-A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
-the strings '_cdata', '_cmeta', '_mlog', '_mimage', '_pmspare',
-'_rimage', '_rlog', '_tdata', '_tmeta'.
+An LV cannot be called '.', '..', 'snapshot' or 'pvmove'. The LV name may also not contain any of the following 
+strings: '_cdata', '_cmeta', '_mlog', '_mimage', '_pmspare', '_rimage', '_rlog', '_tdata' or '_tmeta'.
 A directory bearing the name of each Volume Group is created under /dev when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic link leading to a device node.
 Links or nodes in /dev/mapper are intended only for internal use and the precise format and escaping might change between releases and distributions.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cf8d2c0..185cd59 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2217,7 +2217,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 		if (!vg_commit(lv->vg))
 			return_0;
 		r = 1;
-		log_print_unless_silent("Merging of snapshot %s will start "
+		log_print_unless_silent("Merging of snapshot %s will occur on "
 					"next activation of %s.",
 					display_lvname(lv), display_lvname(origin));
 		goto out;


