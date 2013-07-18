From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:39 +0000 (UTC)
Subject: master - thin: fix error path in creation path
Message-ID: <20130718162639.8B95D60DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7afa9cebcbce0232c0c889cb3f112f66d10a79b0
Commit:        7afa9cebcbce0232c0c889cb3f112f66d10a79b0
Parent:        1d3f7953bda1826fb5eb957ae6dcefc9285454a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 17 15:26:41 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

thin: fix error path in creation path

Remove some calls to revert_new_lv when no LV has been created/commited so far.
When the pool update failed - then only revert is needed.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   20 +++++++-------------
 2 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 641fd53..7b2c2d0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Correct thin creation error paths.
   Use local activation for clearing snapshot COW device.
   Add lvm2-activation-net systemd unit to activate LVs on net-attached storage.
   Release memory allocated with _cached_info().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a5c0d73..2bfd65e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5646,10 +5646,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 		if (!(first_seg(lv)->device_id =
-		      get_free_pool_device_id(first_seg(pool_lv)))) {
-			stack;
-			goto revert_new_lv;
-		}
+		      get_free_pool_device_id(first_seg(pool_lv))))
+			return_NULL;
 		/*
 		 * Check if using 'external origin' or the 'normal' snapshot
 		 * within the same thin pool
@@ -5663,17 +5661,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				log_error("Cannot use active LV for the external origin.");
 				return 0; // We can't be sure device is read-only
 			}
-			if (!attach_thin_external_origin(first_seg(lv), org)) {
-				stack;
-				goto revert_new_lv;
-			}
+			if (!attach_thin_external_origin(first_seg(lv), org))
+				return_NULL;
 		}
 
 		if (!attach_pool_message(first_seg(pool_lv),
-					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0)) {
-			stack;
-			goto revert_new_lv;
-		}
+					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
+			return_NULL;
 	} else if (seg_is_raid(lp)) {
 		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
@@ -5734,7 +5728,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 			/* At this point remove pool messages, snapshot is active */
 			if (!update_pool_lv(first_seg(org)->pool_lv, 0)) {
 				stack;
-				goto deactivate_and_revert_new_lv;
+				goto revert_new_lv;
 			}
 		}
 		if ((lp->activate != CHANGE_AN) && (lp->activate != CHANGE_ALN)) {


