From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:35 +0000 (UTC)
Subject: dev-mornfall-lvmcache - snapshot: require 3 chunks for creation
Message-ID: <20130605120435.9885E6101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59962d8d3e1c402da02f7bf1b09978f570fd09d5
Commit:        59962d8d3e1c402da02f7bf1b09978f570fd09d5
Parent:        39705ed20123d394f1f0d122704855ec783973da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:39:33 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:28:03 2013 +0200

snapshot: require 3 chunks for creation

There is no point in creation of 2chunks snapshot,
since the snapshot is invalidated immeditelly with the first write
as there is no free chunk for COW blocks
(2 chunks are used by the snap header and the 1st. metadata chunk).

Enhance error message about the lowest usable size.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1888c62..256adec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  For creation of snapshot require size for at least 3 chunks.
   Fix lvresize --use-policies of VALID but 100% full snapshot.
   Do not accept size parameters bigger then 16EiB.
   Fix release of PV's fid in free_pv_fid().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index af000af..48a1515 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -47,6 +47,8 @@ typedef enum {
 #define A_CLING_BY_TAGS		0x08	/* Must match tags against existing segment */
 #define A_CAN_SPLIT		0x10
 
+#define SNAPSHOT_MIN_CHUNKS	3       /* Minimum number of chunks in snapshot */
+
 /*
  * Constant parameters during a single allocation attempt.
  */
@@ -4543,8 +4545,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		return NULL;
 	}
 
-	if (lp->snapshot && !seg_is_thin(lp) && ((uint64_t)lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
-		log_error("Unable to create a snapshot smaller than 2 chunks.");
+	if (lp->snapshot && !seg_is_thin(lp) &&
+	    ((uint64_t)(lp->extents * vg->extent_size) < (SNAPSHOT_MIN_CHUNKS * lp->chunk_size))) {
+		log_error("Unable to create a snapshot smaller than "
+			  DM_TO_STRING(SNAPSHOT_MIN_CHUNKS) " chunks (%u extents, %s).",
+			  (unsigned) (((uint64_t) SNAPSHOT_MIN_CHUNKS * lp->chunk_size +
+				       vg->extent_size - 1) / vg->extent_size),
+			  display_size(cmd, (uint64_t) SNAPSHOT_MIN_CHUNKS * lp->chunk_size));
 		return NULL;
 	}
 


