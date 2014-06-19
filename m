From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 19 Jun 2014 15:56:30 +0000 (UTC)
Subject: master - pvmove: Clean-up iterator.
Message-ID: <20140619155630.3D8AD60CCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3964a1a89f52584878c09cf93bc971b96c0d3de1
Commit:        3964a1a89f52584878c09cf93bc971b96c0d3de1
Parent:        f16da6ef23c75b966f94a27b45ca57bacaa13d20
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 19 10:52:09 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 19 10:52:09 2014 -0500

pvmove: Clean-up iterator.

In 'find_pvmove_lv', separate the code that searches the atomic
pvmove LVs from the code that searches the normal pvmove LVs.  This
cleans up the segment iterator code a bit.
---
 lib/metadata/mirror.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index ca0c2a1..484b1f1 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1559,14 +1559,29 @@ struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 		if (!(lv->status & lv_type))
 			continue;
 
-		/* Check segment origins point to pvname */
+		/*
+		 * If this is an atomic pvmove, the first
+		 * segment will be a mirror containing
+		 * mimages (i.e. AREA_LVs)
+		 */
+		if (seg_type(first_seg(lv), 0) == AREA_LV) {
+			seg = first_seg(lv);            /* the mirror segment */
+			seg = first_seg(seg_lv(seg, 0)); /* mimage_0 segment0 */
+			if (seg_dev(seg, 0) != dev)
+				continue;
+			return lv;
+		}
+
+		/*
+		 * If this is a normal pvmove, check all the segments'
+		 * first areas for the requested device
+		 */
 		dm_list_iterate_items(seg, &lv->segments) {
-			if (seg_type(seg, 0) == AREA_LV) /* Atomic pvmove */
-				seg = first_seg(seg_lv(seg, 0));
-			if (seg_type(seg, 0) != AREA_PV) /* Segment pvmove */
+			if (seg_type(seg, 0) != AREA_PV)
 				continue;
 			if (seg_dev(seg, 0) != dev)
 				continue;
+
 			return lv;
 		}
 	}


