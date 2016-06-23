From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:49 +0000 (UTC)
Subject: master - lvresize: check pvh list is vg->pvs
Message-ID: <20160623130149.88AC5608F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d30c2cec880e22ac2ce6cb6a1ee09584f2dc6aae
Commit:        d30c2cec880e22ac2ce6cb6a1ee09584f2dc6aae
Parent:        f45b68940667563e1a8d3bbd5d30864c04381bdf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 16 14:39:26 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:09 2016 +0200

lvresize: check pvh list is vg->pvs

Instead of checking lp->argc for arg count, compare directly whether
passed pvh is vg->pvs.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 562047c..f4abc4f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4785,7 +4785,7 @@ static int _lvresize_extents_from_percent(struct logical_volume *lv, struct lvre
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_PVS:
-			if (lp->argc) {
+			if (pvh != &vg->pvs) {
 				pv_extent_count = pv_list_extents_free(pvh);
 				lp->extents = percent_of_extents(lp->extents, pv_extent_count,
 								 (lp->sign != SIGN_MINUS));
@@ -5228,7 +5228,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	}
 	alloc = lp->alloc ? : lv->alloc;
 
-	if ((lp->resize == LV_REDUCE) && lp->argc)
+	if ((lp->resize == LV_REDUCE) && (pvh != &vg->pvs))
 		log_print_unless_silent("Ignoring PVs on command line when reducing.");
 
 	/* Request confirmation before operations that are often mistakes. */


