From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Sep 2018 16:29:37 -0400
Subject: master - metadata: clarify comments about max size
Message-ID: <201809242029.w8OKTbZm030606@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a49f494c4d9a3551fe63c702a9e8c3495fe066d0
Commit:        a49f494c4d9a3551fe63c702a9e8c3495fe066d0
Parent:        6be1efd13d212967e8518a46e5bce4ba81ab3b94
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 24 15:27:03 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 24 15:27:03 2018 -0500

metadata: clarify comments about max size

Since there is now a direct limit of half the space.
---
 lib/format_text/format-text.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c388a72..9634e47 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1441,22 +1441,21 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	uint32_t wrap = 0;
 	unsigned int len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
-
-	/*
-	 * For the case where the metadata area is unused, we say that half of
-	 * it is available, based on the fact that we keep two consecutive
-	 * copies of the metadata in the area, so each copy can be as large as
-	 * half the area.  (Technically, one of those could be less than half
-	 * and another could be more than half.)
-	 */
-	if (mda_free_sectors)
-		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
+	uint64_t max_size;
 
 	if (!mdah) {
 		log_error(INTERNAL_ERROR "read_metadata_location_summary called with NULL pointer for mda_header");
 		return 0;
 	}
 
+	/*
+	 * For the case where the metadata area is unused, half is available.
+	 */
+	if (mda_free_sectors) {
+		max_size = ((mdah->size - MDA_HEADER_SIZE) / 2) - 512;
+		*mda_free_sectors = max_size >> SECTOR_SHIFT;
+	}
+
 	rlocn = mdah->raw_locns; /* slot0, committed metadata */
 
 	/*
@@ -1567,12 +1566,11 @@ int read_metadata_location_summary(const struct format_type *fmt,
 
 	if (mda_free_sectors) {
 		/*
-		 * Report remaining space on the assumption that a single copy
-		 * of metadata can be as large as half the total metadata
-		 * space, minus 512 because each copy is rounded to begin
-		 * on a sector boundary.
+		 * Report remaining space given that a single copy of metadata
+		 * can be as large as half the total metadata space, minus 512
+		 * because each copy is rounded to begin on a sector boundary.
 		 */
-		uint64_t max_size = ((mdah->size - MDA_HEADER_SIZE) / 2) - 512;
+		max_size = ((mdah->size - MDA_HEADER_SIZE) / 2) - 512;
 
 		if (rlocn->size >= max_size)
 			*mda_free_sectors = UINT64_C(0);


