From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 30 May 2017 13:16:18 -0400
Subject: master - lvconvert: reject changing number of stripes on single core
Message-ID: <201705301716.v4UHGIDf018737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3719f4bc5441cb5f29ad4beb91ccaa6b234ea8e1
Commit:        3719f4bc5441cb5f29ad4beb91ccaa6b234ea8e1
Parent:        c245996d700458f6ab159a387483736f1c1a6fbf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue May 30 19:14:32 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue May 30 19:14:32 2017 +0200

lvconvert: reject changing number of stripes on single core

Reject any stripe adding/removing reshape on raid4/5/6/10 because
of related MD kernel deadlock on single core systems until
we get a proper fix in MD.

Related: rhbz1443999
---
 lib/metadata/raid_manip.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8a70600..80541fd 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2322,6 +2322,12 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	/* Handle disk addition reshaping */
 	if (old_image_count < new_image_count) {
+		/* FIXME: remove once MD kernel rhbz1443999 got fixed. */
+		if (sysconf(_SC_NPROCESSORS_ONLN) < 2) {
+			log_error("Can't add stripes to LV %s on single core.", display_lvname(lv));
+			return 0;
+		}
+
 		if (!_raid_reshape_add_images(lv, new_segtype, yes,
 					      old_image_count, new_image_count,
 					      new_stripes, new_stripe_size, allocate_pvs))
@@ -2329,6 +2335,12 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	/* Handle disk removal reshaping */
 	} else if (old_image_count > new_image_count) {
+		/* FIXME: remove once MD kernel rhbz1443999 got fixed. */
+		if (sysconf(_SC_NPROCESSORS_ONLN) < 2) {
+			log_error("Can't remove stripes from LV %s on single core.", display_lvname(lv));
+			return 0;
+		}
+
 		if (!_raid_reshape_remove_images(lv, new_segtype, yes, force,
 						 old_image_count, new_image_count,
 						 new_stripes, new_stripe_size,


