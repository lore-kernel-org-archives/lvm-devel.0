From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 16:41:27 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110819164127.15747.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 16:41:27

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	avoid multi-line calc with incorrect intermediate var contents

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.274&r2=1.275

--- LVM2/lib/metadata/lv_manip.c	2011/08/18 19:41:21	1.274
+++ LVM2/lib/metadata/lv_manip.c	2011/08/19 16:41:26	1.275
@@ -1541,28 +1541,28 @@
 					    struct alloc_state *alloc_state)
 {
 	const char *metadata_type;
-	uint32_t p_areas_count, p_area_size;
+	uint32_t parallel_areas_count, parallel_area_size;
 	uint32_t metadata_count, metadata_size;
 
-	p_area_size = (ah->new_extents - alloc_state->allocated);
-	p_area_size /= ah->area_multiple;
-	p_area_size -= (ah->alloc_and_split_meta) ? ah->log_len : 0;
-	p_areas_count = ah->area_count + ah->parity_count;
+	parallel_area_size = (ah->new_extents - alloc_state->allocated) / ah->area_multiple -
+		      ((ah->alloc_and_split_meta) ? ah->log_len : 0);
+
+	parallel_areas_count = ah->area_count + ah->parity_count;
 
 	metadata_size = ah->log_len;
 	if (ah->alloc_and_split_meta) {
 		metadata_type = "RAID metadata area";
-		metadata_count = p_areas_count;
+		metadata_count = parallel_areas_count;
 	} else {
 		metadata_type = "mirror log";
 		metadata_count = alloc_state->log_area_count_still_needed;
 	}
 
 	log_debug("Still need %" PRIu32 " total extents:",
-		p_area_size * p_areas_count + metadata_size * metadata_count);
+		parallel_area_size * parallel_areas_count + metadata_size * metadata_count);
 	log_debug("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
 		  " parity) parallel areas of %" PRIu32 " extents each",
-		  p_areas_count, ah->area_count, ah->parity_count, p_area_size);
+		  parallel_areas_count, ah->area_count, ah->parity_count, parallel_area_size);
 	log_debug("  %" PRIu32 " %ss of %" PRIu32 " extents each",
 		  metadata_count, metadata_type, metadata_size);
 }


