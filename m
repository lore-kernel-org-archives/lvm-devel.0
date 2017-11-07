From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:05 -0500
Subject: master - coverity: avoid overflow_before_widen
Message-ID: <201711072036.vA7Ka5nB007671@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2354fb3fe45c6e2739a0a902f378c70c5422ac48
Commit:        2354fb3fe45c6e2739a0a902f378c70c5422ac48
Parent:        56b527a6fbf6f886af4c78dd118867e4513c6a9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 18:24:15 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

coverity: avoid overflow_before_widen

TODO: it likely should be checked value is >0...
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f48169e..da00905 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1842,7 +1842,7 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 
 	/* Externally visible LV size w/o reshape space */
 	lv->le_count = seg->len = new_le_count;
-	lv->size = (uint64_t) (lv->le_count - new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
+	lv->size = (lv->le_count - (uint64_t) new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
 	/* seg->area_len does not change */
 
 	if (old_image_count < new_image_count) {


