From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Jan 2020 04:32:42 -0500
Subject: master - raid: more limitted prohibition of stacked raid usage
Message-ID: <37125.120012304323600181@us-mta-267.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7bf7091c35d3d34aae0d118fa4b78cd30cd4778
Commit:        d7bf7091c35d3d34aae0d118fa4b78cd30cd4778
Parent:        7078dd01e86b176aa5bcb964f57db4ba108eeb4e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 16 16:43:55 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 10:32:15 2020 +0100

raid: more limitted prohibition of stacked raid usage

We actually need to prohibit only reshaping cases which are
running over multiple commands.
---
 lib/metadata/raid_manip.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4855039..486dea1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6210,6 +6210,13 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	if (seg_flag) {
 		if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
 			return_0;
+
+		/* FIXME Can't reshape volume in use - aka not toplevel devices */
+		if (!dm_list_empty(&seg_from->lv->segs_using_this_lv)) {
+			log_error("Can't reshape stacked volume %s.", display_lvname(seg_from->lv));
+			return 0;
+		}
+
 		if (segtype_sav != *segtype) {
 			log_warn("Replaced LV type %s%s with possible type %s.",
 				 segtype_sav->name, _get_segtype_alias_str(seg_from->lv, segtype_sav),
@@ -6438,12 +6445,6 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t available_slvs, removed_slvs;
 	takeover_fn_t takeover_fn;
 
-	/* FIXME Can't reshape volume in use - aka not toplevel devices */
-	if (!dm_list_empty(&lv->segs_using_this_lv)) {
-		log_error("Can't reshape stacked volume %s.", display_lvname(lv));
-		return 0;
-	}
-
 	/* FIXME If not active, prompt and activate */
 	/* FIXME Some operations do not require the LV to be active */
 	/* LV must be active to perform raid conversion operations */



