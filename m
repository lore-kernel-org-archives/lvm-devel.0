From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:08 +0000 (GMT)
Subject: main - cleanup: move common condition
Message-ID: <20210315101408.17FFC3858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fab9987ad73d1de55f21f71fed065525aa4cf4d5
Commit:        fab9987ad73d1de55f21f71fed065525aa4cf4d5
Parent:        b563c926ba348be14988889a581c81ca09ca66e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 13:15:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

cleanup: move common condition

---
 lib/metadata/lv_manip.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9b1eefe60..ec8704ce7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6834,12 +6834,12 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	struct lv_list *lvl;
 	struct logical_volume *origin;
 
-	if (lv_is_cow(lv)) {
+	if (!level && lv_is_cow(lv)) {
 		/*
 		 * A merging snapshot cannot be removed directly unless
 		 * it has been invalidated or failed merge removal is requested.
 		 */
-		if (lv_is_merging_cow(lv) && !level) {
+		if (lv_is_merging_cow(lv)) {
 			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
 			    info.exists && info.live_table) {
 				if (!lv_snapshot_percent(lv, &snap_percent)) {
@@ -6864,7 +6864,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 						  display_lvname(origin_from_cow(lv))) == 'n')
 					goto no_remove;
 			}
-		} else if (!level && lv_is_virtual_origin(origin = origin_from_cow(lv)))
+		} else if (lv_is_virtual_origin(origin = origin_from_cow(lv)))
 			/* If this is a sparse device, remove its origin too. */
 			/* Stacking is not supported */
 			lv = origin;


