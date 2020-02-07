From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 7 Feb 2020 11:18:41 -0500
Subject: master - raid: better place for blocking reshapes
Message-ID: <65581.120020711183500275@us-mta-91.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96985b1373d58b411a80c2985f348466e78cbe6e
Commit:        96985b1373d58b411a80c2985f348466e78cbe6e
Parent:        ffea7daec3d09fb4315104bb346cfa9d6db6f9e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 7 15:14:05 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 7 16:48:48 2020 +0100

raid: better place for blocking reshapes

Still the place can be better to block only particular reshape
operations which ATM cause kernel problems.

We check if the new number of images is higher - and prevent to take
conversion if the volume is in use (i.e. thin-pool's data LV).
---
 lib/metadata/raid_manip.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index dfc6fe5..fa1b91a 100644
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
 
@@ -6216,12 +6223,6 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
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



