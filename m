From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Jun 2013 11:47:59 +0000 (UTC)
Subject: master - cleanup: code swap
Message-ID: <20130625114759.5FCA661386@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09dc590b67518b3e90944aea981be196dd9387a0
Commit:        09dc590b67518b3e90944aea981be196dd9387a0
Parent:        2a059f2358d0a339d4d8095fbde08b06409eb131
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 24 11:48:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

cleanup: code swap

Use easier to read positive query and indent line.
---
 tools/lvcreate.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 972b36a..e9e00be 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -259,7 +259,7 @@ static int _update_extents_params(struct volume_group *vg,
 	 */
 	if (lcp->pv_count) {
 		if (!(lp->pvh = create_pv_list(vg->cmd->mem, vg,
-					   lcp->pv_count, lcp->pvs, 1)))
+					       lcp->pv_count, lcp->pvs, 1)))
 			return_0;
 	} else
 		lp->pvh = &vg->pvs;
@@ -272,12 +272,11 @@ static int _update_extents_params(struct volume_group *vg,
 			lp->extents = percent_of_extents(lp->extents, vg->free_count, 0);
 			break;
 		case PERCENT_PVS:
-			if (!lcp->pv_count)
-				lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
-			else {
+			if (lcp->pv_count) {
 				pv_extent_count = pv_list_extents_free(lp->pvh);
 				lp->extents = percent_of_extents(lp->extents, pv_extent_count, 0);
-			}
+			} else
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
 		case PERCENT_LV:
 			log_error("Please express size as %%VG, %%PVS, or "


