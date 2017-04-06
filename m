From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 6 Apr 2017 13:09:31 -0400
Subject: master - lvconvert: avoid error message on raid1 -> raid4 conversion
Message-ID: <201704061709.v36H9VND009444@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b1a96b9b3650f8776e9d09573bc7754f283e234
Commit:        3b1a96b9b3650f8776e9d09573bc7754f283e234
Parent:        0f65d7ec3a7325165af1a9f722cb760fd363e932
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 19:09:05 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 19:09:05 2017 +0200

lvconvert: avoid error message on raid1 -> raid4 conversion

Avoid error message
"Logical Volume *_rimage_0 already exists in volume group,,,"
on takeover conversion from a 2-legged raid1 to raid4
(aiming to reshape it adding images).

Resolves: rhbz1439398
---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8c58f3c..f360254 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5099,7 +5099,6 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	    !_clear_meta_lvs(lv))
 		return_0;
 
-
 	extents_copied = seg->extents_copied;
 	seg_len = seg->len;
 	stripe_size = seg->stripe_size;
@@ -5166,7 +5165,8 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 						       _pre_raid_add_legs, NULL))
 		return 0;
 
-	if (segtype_is_raid4(new_segtype)) {
+	if (segtype_is_raid4(new_segtype) &&
+	    seg->area_count != 2) {
 		/* We had to rename SubLVs because of collision free shifting, rename back... */
 		if (!_rename_area_lvs(lv, NULL))
 			return_0;


