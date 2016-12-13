From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 20:31:59 +0000 (UTC)
Subject: master - libdm: break up _stats_get_extents_for_file()
Message-ID: <20161213203159.3962B60659@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb6557221715b30a374be46e4a52f79cd7bbed44
Commit:        eb6557221715b30a374be46e4a52f79cd7bbed44
Parent:        ea9af3e290879403d99dd602153ff9d0ad0de8de
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 12:03:00 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 20:25:45 2016 +0000

libdm: break up _stats_get_extents_for_file()

Split out the loop that iterates over each batch of FIEMAP
extent data from the function that sets up and calls the ioctl
to reduce nesting and simplify local variable use:

  _stats_get_extents_for_file()
  ->  _stats_map_extents()

The _stats_map_extents() function is responsible for detecting
eof and extent boundaries and adding whole, allocated extents
to the file extent table for region creation.
---
 libdm/libdm-stats.c |  145 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 88 insertions(+), 57 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 2d2a032..d9f0427 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4226,6 +4226,82 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 ((ext).fe_physical != (exp))
 
 /*
+ * Copy fields from fiemap_extent 'from' to the fiemap_extent
+ * pointed to by 'to'.
+ */
+#define ext_copy(to, from)	\
+do {				\
+	*(to) = *(from);	\
+} while (0)
+
+static uint64_t _stats_map_extents(struct dm_pool *mem,
+				   struct fiemap *fiemap,
+				   struct fiemap_extent *fm_ext,
+				   struct fiemap_extent *fm_last,
+				   struct fiemap_extent *fm_pending,
+				   uint64_t next_extent,
+				   int *eof)
+{
+	uint64_t expected = 0, nr_extents = next_extent;
+	unsigned int i;
+
+	/*
+	 * Loop over the returned extents adding the fm_pending extent
+	 * to the table of extents each time a discontinuity (or eof)
+	 * is detected.
+	 *
+	 * We use a pointer to fm_pending in the caller since it is
+	 * possible that logical extents comprising a single physical
+	 * extent are returned by successive FIEMAP calls.
+	 */
+	for (i = 0; i < fiemap->fm_mapped_extents; i++) {
+		expected = fm_last->fe_physical + fm_last->fe_length;
+
+		if (fm_ext[i].fe_flags & FIEMAP_EXTENT_LAST)
+			*eof = 1;
+
+		/* cannot map extents that are not yet allocated. */
+		if (fm_ext[i].fe_flags
+		    & (FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_DELALLOC))
+			continue;
+
+		if (ext_boundary(fm_ext[i], expected)) {
+			if (!_stats_add_extent(mem, fm_pending, nr_extents))
+				goto_bad;
+			nr_extents++;
+			/* Begin a new pending extent. */
+			ext_copy(fm_pending, fm_ext + i);
+		} else {
+			expected = 0;
+			/* Begin a new pending extent for extent 0. */
+			if (fm_ext[i].fe_logical == 0)
+				ext_copy(fm_pending, fm_ext + i);
+			else
+				/* accumulate this logical extent's length */
+				fm_pending->fe_length += fm_ext[i].fe_length;
+		}
+		*fm_last = fm_ext[i];
+	}
+
+	/*
+	 * If the file only has a single extent, no boundary is ever
+	 * detected to trigger addition of the first extent.
+	 */
+	if (fm_ext[i].fe_logical == 0)
+		_stats_add_extent(mem, fm_pending, nr_extents);
+
+	fiemap->fm_start = (fm_ext[i - 1].fe_logical +
+			    fm_ext[i - 1].fe_length);
+
+	/* return the number of extents found in this call. */
+	return nr_extents - next_extent;
+bad:
+	/* signal mapping error to caller */
+	*eof = -1;
+	return 0;
+}
+
+/*
  * Read the extents of an open file descriptor into a table of struct _extent.
  *
  * Based on e2fsprogs/misc/filefrag.c::filefrag_fiemap().
@@ -4236,16 +4312,12 @@ static int _stats_add_extent(struct dm_pool *mem, struct fiemap_extent *fm_ext,
 static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 						   uint64_t *count)
 {
-	uint64_t *buf;
+	struct fiemap_extent fm_last = {0}, fm_pending = {0}, *fm_ext = NULL;
 	struct fiemap *fiemap = NULL;
-	struct fiemap_extent *fm_ext = NULL;
-	struct fiemap_extent fm_last = {0}, fm_pending = {0};
+	int eof = 0, nr_extents = 0;
 	struct _extent *extents;
-	unsigned long long expected = 0;
 	unsigned long flags = 0;
-	unsigned int i, num = 0;
-	int tot_extents = 0, n = 0;
-	int last = 0;
+	uint64_t *buf;
 	int rc;
 
 	buf = dm_zalloc(STATS_FIE_BUF_LEN);
@@ -4284,67 +4356,26 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 			goto bad;
 		}
 
-		/* If 0 extents are returned, then more ioctls are not needed */
+		/* If 0 extents are returned, more ioctls are not needed */
 		if (fiemap->fm_mapped_extents == 0)
 			break;
 
-		for (i = 0; i < fiemap->fm_mapped_extents; i++) {
-			expected = fm_last.fe_physical + fm_last.fe_length;
+		nr_extents += _stats_map_extents(mem, fiemap, fm_ext, &fm_last,
+						 &fm_pending, nr_extents, &eof);
 
-			if (fm_ext[i].fe_flags & FIEMAP_EXTENT_LAST)
-				last = 1;
-
-			/* cannot map extents that are not yet allocated. */
-			if (fm_ext[i].fe_flags
-			    & (FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_DELALLOC))
-				continue;
-
-			if (ext_boundary(fm_ext[i], expected)) {
-				tot_extents++;
-				if (!_stats_add_extent(mem, &fm_pending,
-						       fm_pending.fe_flags))
-					goto_bad;
-				/* Begin a new pending extent. */
-				fm_pending.fe_flags = tot_extents - 1;
-				fm_pending.fe_physical = fm_ext[i].fe_physical;
-				fm_pending.fe_logical = fm_ext[i].fe_logical;
-				fm_pending.fe_length = fm_ext[i].fe_length;
-			} else {
-				expected = 0;
-				if (!tot_extents)
-					tot_extents = 1;
-				/* Begin a new pending extent for extent 0. */
-				if (fm_ext[i].fe_logical == 0) {
-					fm_pending.fe_flags = tot_extents - 1;
-					fm_pending.fe_physical = fm_ext[i].fe_physical;
-					fm_pending.fe_logical = fm_ext[i].fe_logical;
-					fm_pending.fe_length = fm_ext[i].fe_length;
-				} else
-					fm_pending.fe_length += fm_ext[i].fe_length;
-			}
-			num += tot_extents;
-			fm_last = fm_ext[i];
-			n++;
-		}
-
-		/*
-		 * If the file only has a single extent, no boundary is ever
-		 * detected to trigger addition of the first extent.
-		 */
-		if (fm_ext[i].fe_logical == 0)
-			_stats_add_extent(mem, &fm_pending, fm_pending.fe_flags);
+		/* check for extent mapping error */
+		if (eof < 0)
+			goto bad;
 
-		fiemap->fm_start = (fm_ext[i - 1].fe_logical +
-				    fm_ext[i - 1].fe_length);
-	} while (last == 0);
+	} while (eof == 0);
 
-	if (!tot_extents) {
+	if (!nr_extents) {
 		log_error("Cannot map file: no allocated extents.");
 		goto bad;
 	}
 
 	/* return total number of extents */
-	*count = tot_extents;
+	*count = nr_extents;
 	extents = dm_pool_end_object(mem);
 
 	/* free FIEMAP buffer. */


