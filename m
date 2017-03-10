From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:59 -0500
Subject: master - lvcreate: do not round cache volumes on cache chunks
Message-ID: <201703101835.v2AIZxMw028299@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=298d12c4590ccca26b92e1457c72c6369a32d3e9
Commit:        298d12c4590ccca26b92e1457c72c6369a32d3e9
Parent:        f24a1f06b2a9856c2bde0f8ee740bb9c3c695c35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 17:15:56 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvcreate: do not round cache volumes on cache chunks

Since cache chunk might be huge and there is no technical need
to enforce rounding and there is actually more 'real' VG space
used then necessary - keep rounding on 'chunk' bounrary only
for thin volumes - where it's the space used anyway.

NB: we support conversion of any-size 'existing' LV into cached LV.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   25 ++++++++++++-------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 00465cc..61b01b6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Skip rounding on cache chunk size boudary when create cache LV.
   Improve cache_set_params support for chunk_size selection.
   Fix metadata profile allocation/cache_[mode|policy] setting.
   Fix missing support for using allocation/cache_pool_chunk_size setting.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5ef9d73..120eb58 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7402,21 +7402,20 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		/* Validate volume size to to aling on chunk for small extents */
-		/* Cache chunk size is always set */
-		size = first_seg(pool_lv)->chunk_size;
-		if (size > vg->extent_size) {
-			/* Align extents on chunk boundary size */
-			size = ((uint64_t)vg->extent_size * lp->extents + size - 1) /
-				size * size / vg->extent_size;
-			if (size != lp->extents) {
-				log_print_unless_silent("Rounding size (%d extents) up to chunk boundary "
-							"size (%d extents).", lp->extents, size);
-				lp->extents = size;
+		if (seg_is_thin_volume(lp)) {
+			/* Validate volume size to to aling on chunk for small extents */
+			size = first_seg(pool_lv)->chunk_size;
+			if (size > vg->extent_size) {
+				/* Align extents on chunk boundary size */
+				size = ((uint64_t)vg->extent_size * lp->extents + size - 1) /
+					size * size / vg->extent_size;
+				if (size != lp->extents) {
+					log_print_unless_silent("Rounding size (%d extents) up to chunk boundary "
+								"size (%d extents).", lp->extents, size);
+					lp->extents = size;
+				}
 			}
-		}
 
-		if (seg_is_thin_volume(lp)) {
 			thin_pool_was_active = lv_is_active(pool_lv);
 			if (lv_is_new_thin_pool(pool_lv)) {
 				if (!check_new_thin_pool(pool_lv))


