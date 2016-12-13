From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 09:55:58 +0000 (UTC)
Subject: master - libdm: fix _stats_get_extents_for_file()
Message-ID: <20161213095558.66CBD6051E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93f420caf4e58f468919f40a9f3f9c20157affd0
Commit:        93f420caf4e58f468919f40a9f3f9c20157affd0
Parent:        87117c2b2546231c789f92c75590f053a8fb987c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Dec 12 20:40:27 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 09:09:25 2016 +0000

libdm: fix _stats_get_extents_for_file()

Handle files that contain multiple logical extents in a single
physical extent properly:

  - In FIEMAP terms a logical extent is a contiguous range of
    sectors in the file's address space.

  - One or more physically adjacent logical extents comprise a
    physical extent: these are the disk areas that will be mapped
    to regions.

  - An extent boundary occurs when the start sector of extent
    n+1 is not equal to (n.start + n.length).

This requires that we accumulate the length values of extents
returned by FIEMAP until a discontinuity is found (since each
struct fiemap_extent returned by FIEMAP only represents a single
logical extent, which may be contiguous with other logical
extents on-disk).

This avoids creating large numbers of regions for physically
adjacent (logical) extents and fixes the earlier behaviour which
would only map the first logical extent of the physical extent,
leaving gaps in the region table for these files.
---
 WHATS_NEW_DM        |    3 +-
 libdm/libdm-stats.c |   56 +++++++++++++++++++++++++++++++++-----------------
 2 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f402113..ab32bdb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,8 +1,9 @@
 Version 1.02.138 - 
 =====================================
+  Fix file mapping for extents with physically adjacent extents.
   Validation vsnprintf result in runtime translate of dm_log (1.02.136).
   Separate filemap extent allocation from region table.
-  Fix segmentation fault when filemap region creation fails
+  Fix segmentation fault when filemap region creation fails.
   Fix performance of region cleanup for failed filemap creation.
   Fix very slow region deletion with many regions.
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 850aa49..56a38f2 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4194,10 +4194,9 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 }
 
 /* test for the boundary of an extent */
-#define ext_boundary(ext, exp, exp_dense)	\
-(((ext).fe_logical != 0) &&			\
-((ext).fe_physical != (exp)) &&			\
-((ext).fe_physical != (exp_dense)))
+#define ext_boundary(ext, exp)		\
+((ext).fe_logical != 0) &&		\
+((ext).fe_physical != (exp))
 
 /*
  * Read the extents of an open file descriptor into a table of struct _extent.
@@ -4213,10 +4212,9 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	uint64_t *buf;
 	struct fiemap *fiemap = NULL;
 	struct fiemap_extent *fm_ext = NULL;
-	struct fiemap_extent fm_last = {0};
+	struct fiemap_extent fm_last = {0}, fm_pending = {0};
 	struct _extent *extents;
 	unsigned long long expected = 0;
-	unsigned long long expected_dense = 0;
 	unsigned long flags = 0;
 	unsigned int i, num = 0;
 	int tot_extents = 0, n = 0;
@@ -4264,31 +4262,51 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 			break;
 
 		for (i = 0; i < fiemap->fm_mapped_extents; i++) {
-			expected_dense = fm_last.fe_physical +
-					 fm_last.fe_length;
-			expected = fm_last.fe_physical +
-				   fm_ext[i].fe_logical - fm_last.fe_logical;
-			if (ext_boundary(fm_ext[i], expected, expected_dense)) {
+			expected = fm_last.fe_physical + fm_last.fe_length;
+
+			if (fm_ext[i].fe_flags & FIEMAP_EXTENT_LAST)
+				last = 1;
+
+			/* cannot map extents that are not yet allocated. */
+			if (fm_ext[i].fe_flags
+			    & (FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_DELALLOC))
+				continue;
+
+			if (ext_boundary(fm_ext[i], expected)) {
 				tot_extents++;
-				if (!_stats_add_extent(mem, fm_ext + i,
-						       tot_extents - 1))
+				if (!_stats_add_extent(mem, &fm_pending,
+						       fm_pending.fe_flags))
 					goto_bad;
+				/* Begin a new pending extent. */
+				fm_pending.fe_flags = tot_extents - 1;
+				fm_pending.fe_physical = fm_ext[i].fe_physical;
+				fm_pending.fe_logical = fm_ext[i].fe_logical;
+				fm_pending.fe_length = fm_ext[i].fe_length;
 			} else {
 				expected = 0;
 				if (!tot_extents)
 					tot_extents = 1;
-				if (fm_ext[i].fe_logical == 0)
-					if (!_stats_add_extent(mem, fm_ext + i,
-							       tot_extents - 1))
-						goto_bad;
+				/* Begin a new pending extent for extent 0. */
+				if (fm_ext[i].fe_logical == 0) {
+					fm_pending.fe_flags = tot_extents - 1;
+					fm_pending.fe_physical = fm_ext[i].fe_physical;
+					fm_pending.fe_logical = fm_ext[i].fe_logical;
+					fm_pending.fe_length = fm_ext[i].fe_length;
+				} else
+					fm_pending.fe_length += fm_ext[i].fe_length;
 			}
 			num += tot_extents;
-			if (fm_ext[i].fe_flags & FIEMAP_EXTENT_LAST)
-				last = 1;
 			fm_last = fm_ext[i];
 			n++;
 		}
 
+		/*
+		 * If the file only has a single extent, no boundary is ever
+		 * detected to trigger addition of the first extent.
+		 */
+		if (fm_ext[i].fe_logical == 0)
+			_stats_add_extent(mem, &fm_pending, fm_pending.fe_flags);
+
 		fiemap->fm_start = (fm_ext[i - 1].fe_logical +
 				    fm_ext[i - 1].fe_length);
 	} while (last == 0);


