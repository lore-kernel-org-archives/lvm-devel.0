From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:02:59 +0000 (UTC)
Subject: master - thin: send messages to active pool
Message-ID: <20130715140259.6662F60FD0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42881c887777257de42acf695aa3da7693af33d5
Commit:        42881c887777257de42acf695aa3da7693af33d5
Parent:        5658ec2bdc9e5ea816a1dd227ffbb74d6cbfb8f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 11:27:57 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:47:25 2013 +0200

thin: send messages to active pool

If the thin pool is known to be active, messages can be passed
to the pool even when the created thin volume is not going to be
activated.

So we do not need to stack large list of message and validate
and catch creation errors earlier in this case.

Replace the test for valid activation combination with simpler list of
deactivation combinations.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   11 +++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1f1a984..4c662c1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Send thin messages also for active thin pool and inactive thin volume.
   Add activation/auto_set_activation_skip to control activation skip flagging.
   Add 's(k)ip activation' bit to lvs -o lv_attr to indicate skip flag attached.
   Add --ignoreactivationskip to lvcreate/vgchange/lvchange to ignore skip flag.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fa63b78..87f30f7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5548,18 +5548,17 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		}
 	}
 
-	if (seg_is_thin_volume(lp) &&
-	    ((lp->activate == CHANGE_AY) ||
-	     (lp->activate == CHANGE_AE) ||
-	     (lp->activate == CHANGE_ALY))) {
+	if (seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
 		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
 			log_error("Unable to find existing pool LV %s in VG %s.",
 				  lp->pool, vg->name);
 			return NULL;
 		}
-		if (!update_pool_lv(lvl->lv, 1))
-			return_NULL;
+		if (lv_is_active(lvl->lv) ||
+		    ((lp->activate != CHANGE_AN) && (lp->activate != CHANGE_ALN)))
+			if (!update_pool_lv(lvl->lv, 1))
+				return_NULL;
 	}
 
 	if (vg_is_clustered(vg) && segtype_is_raid(lp->segtype)) {


