From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 23:03:26 +0000 (UTC)
Subject: master - thin: enforce local activation when creation new thin
Message-ID: <20151013230326.65D4F60763@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c36d7c90c77f8225432b451cb831711cea01883
Commit:        7c36d7c90c77f8225432b451cb831711cea01883
Parent:        bbef4edd06097a71601b1470a713ded17deb7cba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 14 01:00:35 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 14 01:00:35 2015 +0200

thin: enforce local activation when creation new thin

As we need to check how full thin-pool is - require thin-pool is
locally active.
---
 lib/metadata/lv_manip.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8a0bbcd..7a3d9b9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7088,16 +7088,23 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		if (seg_is_thin_volume(lp)) {
+			thin_pool_was_active = lv_is_active(pool_lv);
 			if (lv_is_new_thin_pool(pool_lv)) {
-				thin_pool_was_active = lv_is_active(pool_lv);
 				if (!check_new_thin_pool(pool_lv))
 					return_NULL;
 				/* New pool is now inactive */
-			} else if (!pool_below_threshold(first_seg(pool_lv))) {
-				log_error("Cannot create new thin volume, free space in "
-					  "thin pool %s reached threshold.",
-					  display_lvname(pool_lv));
-				return NULL;
+			} else {
+				if (!activate_lv_excl_local(cmd, pool_lv)) {
+					log_error("Aborting. Failed to locally activate thin pool %s.",
+						  display_lvname(pool_lv));
+					return 0;
+				}
+				if (!pool_below_threshold(first_seg(pool_lv))) {
+					log_error("Cannot create new thin volume, free space in "
+						  "thin pool %s reached threshold.",
+						  display_lvname(pool_lv));
+					return NULL;
+				}
 			}
 		}
 


