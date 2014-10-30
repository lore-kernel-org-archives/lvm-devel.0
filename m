From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:51 +0000 (UTC)
Subject: master - cleanup: prints and stacks
Message-ID: <20141030230051.7636F60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a6cf3d9f4b43e0d47ac686d8acc5f280d4bfd70
Commit:        9a6cf3d9f4b43e0d47ac686d8acc5f280d4bfd70
Parent:        0da749c9a4c488bd336b2c6b3df7d781a812cb47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 11:38:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

cleanup: prints and stacks

---
 lib/metadata/lv_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 49d2300..e5b36df 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4600,21 +4600,21 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	/* If reducing, find stripes, stripesize & size of last segment */
 	if (reducing) {
 		if (lp->stripes || lp->stripe_size || lp->mirrors)
-			log_error("Ignoring stripes, stripesize and mirrors "
-				  "arguments when reducing");
+			log_print_unless_silent("Ignoring stripes, stripesize and mirrors "
+						"arguments when reducing.");
 
 		if (lp->sign == SIGN_MINUS) 
 			if (lp->extents_are_pes) {
 				if (lp->extents >= existing_physical_extents) {
 					log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
-					return_0;
+					return 0;
 				}
 				new_extents = existing_physical_extents - lp->extents;
 			} else {
 				new_extents = existing_logical_extents - lp->extents;
 				if (lp->extents >= existing_logical_extents) {
 					log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
-					return_0;
+					return 0;
 				}
 			}
 		else
@@ -4843,7 +4843,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 
 	if (lv_is_thin_pool(lv)) {
 		if (lp->resizefs) {
-			log_warn("Thin pool volumes do not have filesystem.");
+			log_print_unless_silent("Ignoring --resizefs as thin pool volumes do not have filesystem.");
 			lp->resizefs = 0;
 		}
 		lock_lv = lv;
@@ -4854,7 +4854,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	alloc = lp->ac_alloc ?: lv->alloc;
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)
-		log_warn("Ignoring PVs on command line when reducing");
+		log_print_unless_silent("Ignoring PVs on command line when reducing.");
 
 	/* Request confirmation before operations that are often mistakes. */
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&


