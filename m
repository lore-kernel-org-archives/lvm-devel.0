From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 13 Jul 2016 13:17:54 +0000 (UTC)
Subject: master - lv_manip: extension of raid0 causes livelock
Message-ID: <20160713131754.1E37C61167@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df5021a2017e395c68d1bee012a54a1d59c63c90
Commit:        df5021a2017e395c68d1bee012a54a1d59c63c90
Parent:        9c2757349370cb0b098fb3a3d137107543818fd7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 13 15:16:23 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 13 15:17:24 2016 +0200

lv_manip: extension of raid0 causes livelock

A livelock occurs on extension in lv_manip when adjusting the region size,
which doesn't apply to any raid0/raid0_meta LVs (these don't have a bitmap).

Fix by prohibiting the region size adjustment on any such LVs.

- resolves rhbz1354604
---
 lib/metadata/lv_manip.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5cf9618..d11b125 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3921,14 +3921,16 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 
 	/*
 	 * The MD bitmap is limited to being able to track 2^21 regions.
-	 * The region_size must be adjusted to meet that criteria.
+	 * The region_size must be adjusted to meet that criteria
+	 * unless raid0/raid0_meta, which doesn't have a bitmap.
 	 */
-	while (seg_is_raid(seg) && (seg->region_size < (lv->size / (1 << 21)))) {
-		seg->region_size *= 2;
-		log_very_verbose("Adjusting RAID region_size from %uS to %uS"
-				 " to support large LV size",
-				 seg->region_size/2, seg->region_size);
-	}
+	if (seg_is_raid(seg) && !seg_is_any_raid0(seg))
+		while (seg->region_size < (lv->size / (1 << 21))) {
+			seg->region_size *= 2;
+			log_very_verbose("Adjusting RAID region_size from %uS to %uS"
+					 " to support large LV size",
+					 seg->region_size/2, seg->region_size);
+		}
 
 	return 1;
 }


