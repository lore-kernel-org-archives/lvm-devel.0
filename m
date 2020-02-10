From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 10 Feb 2020 09:45:07 -0500
Subject: stable-2.02 - raid: better place for blocking reshapes
Message-ID: <13679.120021009450200271@us-mta-343.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=253d10f840682f85dad0e4c29f55ff50f94792fa
Commit:        253d10f840682f85dad0e4c29f55ff50f94792fa
Parent:        bcf9556b8fcd16ad8997f80cc92785f295c66701
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 7 15:14:05 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Feb 10 15:44:46 2020 +0100

raid: better place for blocking reshapes

Still the place can be better to block only particular reshape
operations which ATM cause kernel problems.

We check if the new number of images is higher - and prevent to take
conversion if the volume is in use (i.e. thin-pool's data LV).

(cherry picked from commit 96985b1373d58b411a80c2985f348466e78cbe6e)
---
 lib/metadata/raid_manip.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0b0c09181..f51e9c401 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2298,6 +2298,13 @@ static int _raid_reshape(struct logical_volume *lv,
 	if ((new_image_count = new_stripes + seg->segtype->parity_devs) < 2)
 		return_0;
 
+	/* FIXME Can't reshape volume in use - aka not toplevel devices */
+	if (old_image_count < new_image_count &&
+	    !dm_list_empty(&seg->lv->segs_using_this_lv)) {
+		log_error("Unable to convert stacked volume %s.", display_lvname(seg->lv));
+		return 0;
+	}
+
 	if (!_check_max_raid_devices(new_image_count))
 		return_0;
 
@@ -6217,12 +6224,6 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 		if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
 			return_0;
 
-		/* FIXME Can't reshape volume in use - aka not toplevel devices */
-		if (!dm_list_empty(&seg_from->lv->segs_using_this_lv)) {
-			log_error("Can't reshape stacked volume %s.", display_lvname(seg_from->lv));
-			return 0;
-		}
-
 		if (segtype_sav != *segtype) {
 			log_warn("Replaced LV type %s%s with possible type %s.",
 				 segtype_sav->name, _get_segtype_alias_str(seg_from->lv, segtype_sav),



