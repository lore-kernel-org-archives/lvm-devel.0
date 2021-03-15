From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:11 +0000 (GMT)
Subject: main - vg_validate: fix validation of merging thin origin
Message-ID: <20210315101411.800203857C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a18409b6d1d6a90e432b0b0079ce702d0055fa5a
Commit:        a18409b6d1d6a90e432b0b0079ce702d0055fa5a
Parent:        ff712987a5792cfc3fba03889ec4485294386a03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 11:44:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 10:59:09 2021 +0100

vg_validate: fix validation of merging thin origin

Compat code and handle unusual case, where
thin snapshot is also a 'thick snapshot origin' and such
snapshot gets merged into a thin origin.

However since now lv_is_visible() (which is complex function)
replaced &VISIBLE_LV check, the whole this check seems to be
no longer useful as sum of all 3 will always match??
---
 lib/metadata/metadata.c | 25 ++++++-------------------
 1 file changed, 6 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ed1c05f75..cee236e3e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2397,12 +2397,6 @@ int vg_validate(struct volume_group *vg)
 			}
 		}
 
-		if (lv_is_cow(lvl->lv))
-			num_snapshots++;
-
-		if (lv_is_visible(lvl->lv))
-			lv_visible_count++;
-
 		if (!check_lv_segments(lvl->lv, 0)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
@@ -2427,19 +2421,12 @@ int vg_validate(struct volume_group *vg)
 				r = 0;
 			}
 
-		if (lvl->lv->status & VISIBLE_LV)
-			continue;
-
-		/* snapshots */
-		if (lv_is_cow(lvl->lv))
-			continue;
-
-		/* virtual origins are always hidden */
-		if (lv_is_origin(lvl->lv) && !lv_is_virtual_origin(lvl->lv))
-			continue;
-
-		/* count other non-snapshot invisible volumes */
-		hidden_lv_count++;
+		if (lv_is_visible(lvl->lv))
+			lv_visible_count++;
+		else if (lv_is_cow(lvl->lv))
+			num_snapshots++;
+		else		/* count other non-snapshot invisible volumes */
+			hidden_lv_count++;
 
 		/*
 		 *  FIXME: add check for unreferenced invisible LVs


