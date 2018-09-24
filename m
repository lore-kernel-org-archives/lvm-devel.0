From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Sep 2018 16:16:20 -0400
Subject: master - metadata: add direct size limit
Message-ID: <201809242016.w8OKGKpw029227@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6be1efd13d212967e8518a46e5bce4ba81ab3b94
Commit:        6be1efd13d212967e8518a46e5bce4ba81ab3b94
Parent:        91c7e66f2b47f4ef814dcf85e1641d49e5123cc7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 24 14:41:58 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 24 14:41:58 2018 -0500

metadata: add direct size limit

Previously the size was limited by checking if the
old and new copies of the metadata overlapped.
This generally limited the size to about half of
the total space, but it could be larger given the
size differences between old and new.  Now add a
direct check to limit the size to half the space.
---
 lib/format_text/format-text.c |   40 ++++++++++++++++++++++++++++++++++------
 1 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index de4be47..c388a72 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -682,6 +682,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct pv_list *pvl;
 	uint64_t old_start = 0, old_last = 0, old_size = 0, old_wrap = 0;
 	uint64_t new_start = 0, new_last = 0, new_size = 0, new_wrap = 0;
+	uint64_t max_size;
 	char *new_buf = NULL;
 	int overlap;
 	int found = 0;
@@ -722,6 +723,27 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	}
 
 	/*
+	 * The max size of a single copy of text metadata.
+	 *
+	 * The space available for all text metadata is the size of the
+	 * metadata area (mdah->size) minus the sector used for the header.
+	 * Two copies of the text metadata must fit in this space, so it is
+	 * divided in two.  This result is then reduced by 512 because any
+	 * single copy of metadata is rounded to begin on a sector boundary.
+	 */
+
+	max_size = ((mdah->size - MDA_HEADER_SIZE) / 2) - 512;
+
+	if (new_size > max_size) {
+		log_error("VG %s metadata on %s (%llu bytes) exceeds maximum metadata size (%llu bytes)",
+			  vg->name,
+			  dev_name(mdac->area.dev),
+			  (unsigned long long)new_size,
+			  (unsigned long long)max_size);
+		goto out;
+	}
+
+	/*
 	 * rlocn_old is the current, committed, raw_locn data in slot0 on disk.
 	 *
 	 * rlocn_new (mdac->rlocn) is the new, in-memory, raw_locn data for the
@@ -816,6 +838,13 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	/*
 	 * If the new copy of the metadata would overlap the old copy of the
 	 * metadata, it means that the circular metadata buffer is full.
+	 *
+	 * Given the max_size restriction above, two copies of metadata should
+	 * never overlap, so these overlap checks should not be technically
+	 * necessary, and a failure should not occur here.  It's left as a
+	 * sanity check.  For some unknown time, lvm did not enforce a
+	 * max_size, but rather detected the too-large failure by checking for
+	 * overlap between old and new.
 	 */
 
 	if (new_wrap && old_wrap) {
@@ -1540,16 +1569,15 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		/*
 		 * Report remaining space on the assumption that a single copy
 		 * of metadata can be as large as half the total metadata
-		 * space.  Technically, it can be larger if the other copy is
-		 * less.  511 is subtracted from max because the next copy can
-		 * be rounded up by 511 bytes to start on a sector boundary.
+		 * space, minus 512 because each copy is rounded to begin
+		 * on a sector boundary.
 		 */
-		uint64_t max = (mdah->size - MDA_HEADER_SIZE - 511) / 2;
+		uint64_t max_size = ((mdah->size - MDA_HEADER_SIZE) / 2) - 512;
 
-		if (rlocn->size >= max)
+		if (rlocn->size >= max_size)
 			*mda_free_sectors = UINT64_C(0);
 		else
-			*mda_free_sectors = (max - rlocn->size) >> SECTOR_SHIFT;
+			*mda_free_sectors = (max_size - rlocn->size) >> SECTOR_SHIFT;
 	}
 
 	return 1;


