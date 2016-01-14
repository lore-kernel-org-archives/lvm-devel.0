From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:22 +0000 (UTC)
Subject: master - cleanup: simplier formula
Message-ID: <20160114103522.D21A160DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4310dfd4e141bb83320148d245f3ab2cae778f6e
Commit:        4310dfd4e141bb83320148d245f3ab2cae778f6e
Parent:        ebcfd09ba9631b52762b4932fbe06260326b9827
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 8 11:07:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

cleanup: simplier formula

---
 lib/metadata/lv_manip.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 62564c5..1396b86 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4950,21 +4950,14 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			log_print_unless_silent("Ignoring stripes, stripesize and mirrors "
 						"arguments when reducing.");
 
-		if (lp->sign == SIGN_MINUS) 
-			if (lp->extents_are_pes) {
-				if (lp->extents >= existing_physical_extents) {
-					log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
-					return 0;
-				}
-				new_extents = existing_physical_extents - lp->extents;
-			} else {
-				new_extents = existing_logical_extents - lp->extents;
-				if (lp->extents >= existing_logical_extents) {
-					log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
-					return 0;
-				}
+		if (lp->sign == SIGN_MINUS)  {
+			new_extents = lp->extents_are_pes ? existing_physical_extents : existing_logical_extents;
+			if (lp->extents >= new_extents) {
+				log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
+				return 0;
 			}
-		else
+			new_extents -= lp->extents;
+		} else
 			new_extents = lp->extents;
 
 		dm_list_iterate_items(seg, &lv->segments) {


