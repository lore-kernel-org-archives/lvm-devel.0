From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:19 -0400
Subject: master - libdm: make _find_extent() nr_extents argument uint64_t
Message-ID: <201703300904.v2U94JXr019956@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=722542fabb30915653a222a6dca8f34338db4e80
Commit:        722542fabb30915653a222a6dca8f34338db4e80
Parent:        5e74e43896c3b35584e3edfb76fa407adbed862c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:41:33 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:02:35 2017 +0100

libdm: make _find_extent() nr_extents argument uint64_t

---
 libdm/libdm-stats.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b553da5..5a454fd 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4472,7 +4472,7 @@ bad:
 #define MATCH_EXTENT(e, s, l) \
 (((e).start == (s)) && ((e).len == (l)))
 
-static struct _extent *_find_extent(size_t nr_extents, struct _extent *extents,
+static struct _extent *_find_extent(uint64_t nr_extents, struct _extent *extents,
 				    uint64_t start, uint64_t len)
 {
 	size_t i;
@@ -4685,9 +4685,10 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 	 */
 	for (i = 0; i < *count; i++) {
 		if (update) {
-			if ((old_ext = _find_extent(nr_kept, old_extents,
-						       extents[i].start,
-						       extents[i].len))) {
+			if ((old_ext = _find_extent((uint64_t) nr_kept,
+						    old_extents,
+						    extents[i].start,
+						    extents[i].len))) {
 				regions[i] = old_ext->id;
 				continue;
 			}


