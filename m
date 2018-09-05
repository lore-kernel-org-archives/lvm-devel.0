From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 5 Sep 2018 10:41:48 -0400
Subject: 2018-06-01-stable - lvconvert: avoid superfluous interim raid type
Message-ID: <201809051441.w85EfmJX023162@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e03c686191b036a7cd6e570888793ddbdd5f958
Commit:        0e03c686191b036a7cd6e570888793ddbdd5f958
Parent:        3374a592502ef099d38491b0c2020a6945d825b1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 31 19:03:52 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 5 16:41:14 2018 +0200

lvconvert: avoid superfluous interim raid type

When converting striped/raid0*/raid6_n_6 <-> raid4,
avoid superfluous interim raid5_n layout.

Related: rhbz1447809
(cherry picked from commit 22a13043683a5647e8cc4e3aead911e5269ffd2f)
---
 lib/metadata/raid_manip.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d3e3a20..3eee77a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6140,7 +6140,7 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			seg_flag = SEG_RAID6_N_6;
 
 		if (segtype_is_linear(*segtype) ||
-		    (!segtype_is_raid10(*segtype) && !segtype_is_striped(*segtype)))
+		    (!segtype_is_raid4(*segtype) && !segtype_is_raid10(*segtype) && !segtype_is_striped(*segtype)))
 			seg_flag = SEG_RAID5_N;
 
 	/* raid1 -> */
@@ -6209,10 +6209,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 					  lvseg_name(seg_from), display_lvname(seg_from->lv), *new_image_count);
 		}
 
-	/* raid4 -> !raid4/raid5* */
-	} else if (seg_is_raid4(seg_from) &&
-		   !segtype_is_raid4(*segtype) && !segtype_is_any_raid5(*segtype)) {
-		seg_flag = SEG_RAID5_N;
+	/* raid4 -> * */
+	} else if (seg_is_raid4(seg_from) && !segtype_is_raid4(*segtype) && !segtype_is_striped(*segtype)) {
+		seg_flag = segtype_is_any_raid6(*segtype) ? SEG_RAID6_N_6 : SEG_RAID5_N;
 
 	/* raid6 -> striped/raid0/raid5/raid10 */
 	} else if (seg_is_any_raid6(seg_from)) {


