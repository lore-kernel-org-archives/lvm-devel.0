From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Apr 2016 09:27:45 +0000 (UTC)
Subject: master - metadata: log warning instead of error if device not found while checking used and assumed devs
Message-ID: <20160425092745.BB6D260DA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d976c0002f06e97c50bca7dad35d647848ed60f
Commit:        9d976c0002f06e97c50bca7dad35d647848ed60f
Parent:        eb8edccd58a4ac2b313800f4d1839df336e3cab9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 25 11:15:44 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Apr 25 11:27:28 2016 +0200

metadata: log warning instead of error if device not found while checking used and assumed devs

When checking assumed PVs against real devices used for LVs and if
there's no device assigned for an assumed PV (e.g. due to filters),
do log_warn instead of log_error and continue checking LV segments
and associated assumed PVs further, just like we do log_warn elsewhere
in this situation.

This way user will see the warning for each LV which couldn't be
checked completely against real PVs used. Before, we logged only
the very first occurence of missing device for an LV in a VG and we
returned from the function doing this check for all the LVs in VG
immediately which may be a bit misleading because it didn't tell
user about all the other LVs and whether they could be checked
or not.

For example, we have this setup:

[0] fedora/~ # pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda          lvm2 ---  128.00m 128.00m
  /dev/vda2  fedora lvm2 a--   19.49g      0

[0] fedora/~ # lvs -o+devices
  LV   VG     Attr       LSize   Devices
  root fedora -wi-ao----  19.00g /dev/vda2(0)
  swap fedora -wi-ao---- 500.00m /dev/vda2(4864)

Before this patch (only the very first LV in a VG is logged to have a
problem while checking used and assumed devices):

[0] fedora/~ # pvs --config 'devices/filter=["a|/dev/sda|", "r|.*|"]'
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  Couldn't find device for segment belonging to fedora/root while checking used and assumed devices.
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda          lvm2 ---  128.00m 128.00m
  [unknown]  fedora lvm2 a-m   19.49g      0

With this patch applied (all LVs where we hit problem while checking
used and assumed devices are logged and it's warning, not error):

[0] fedora/~ # pvs --config 'devices/filter=["a|/dev/sda|", "r|.*|"]'
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Couldn't find device for segment belonging to fedora/root while checking used and assumed devices.
  WARNING: Couldn't find device for segment belonging to fedora/swap while checking used and assumed devices.
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda          lvm2 ---  128.00m 128.00m
  [unknown]  fedora lvm2 a-m   19.49g      0
---
 lib/metadata/metadata.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f9ce080..1ceed68 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4597,6 +4597,7 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 	struct device *dev;
 	struct lv_segment *seg;
 	uint32_t s;
+	int warned_about_no_dev = 0;
 	char *used_devnames = NULL, *assumed_devnames = NULL;
 
 	if (!(list = dev_cache_get_dev_list_for_lvid(lv->lvid.s + ID_LEN)))
@@ -4629,10 +4630,13 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_PV) {
 				if (!(dev = seg_dev(seg, s))) {
-					log_error("Couldn't find device for segment belonging to "
-						  "%s while checking used and assumed devices.",
-						  display_lvname(lv));
-					return 0;
+					if (!warned_about_no_dev) {
+						log_warn("WARNING: Couldn't find device for segment belonging "
+							 "to %s while checking used and assumed devices.",
+							  display_lvname(lv));
+						warned_about_no_dev = 1;
+					}
+					continue;
 				}
 				if (!(dev->flags & DEV_USED_FOR_LV)) {
 					if (!found_inconsistent) {
@@ -4653,11 +4657,10 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 		if (!dm_pool_grow_object(mem, "\0", 1))
 			return_0;
 		assumed_devnames = dm_pool_end_object(mem);
+		log_warn("WARNING: Device mismatch detected for %s which is accessing %s instead of %s.",
+			 display_lvname(lv), used_devnames, assumed_devnames);
 	}
 
-	log_warn("WARNING: Device mismatch detected for %s which is accessing %s instead of %s.",
-		 display_lvname(lv), used_devnames, assumed_devnames);
-
 	return 1;
 }
 


