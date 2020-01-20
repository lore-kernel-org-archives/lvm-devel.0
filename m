From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Jan 2020 09:22:48 -0500
Subject: stable-2.02 - raid: more limitted prohibition of stacked raid usage
Message-ID: <41474.120012009224600623@us-mta-54.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8ef0307372f13e1a5e74bd5741898f343c520bd
Commit:        f8ef0307372f13e1a5e74bd5741898f343c520bd
Parent:        c66e01569862a421d137eedbf9e6abe4e1152853
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 16 16:43:55 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 20 15:21:38 2020 +0100

raid: more limitted prohibition of stacked raid usage

We actually need to prohibit only reshaping cases which are
running over multiple commands.
---
 lib/metadata/raid_manip.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 548faf1..0b0c091 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6216,6 +6216,13 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
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
@@ -6444,12 +6451,6 @@ int lv_raid_convert(struct logical_volume *lv,
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



