From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 17 May 2017 18:44:02 -0400
Subject: master - lvconvert: fix indent and typo in last commit
Message-ID: <201705172244.v4HMi2Hn009318@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c651b146ef7be080c5006f94c257e2c9815cd7f
Commit:        9c651b146ef7be080c5006f94c257e2c9815cd7f
Parent:        5fe07d3574ddce3d194f0fa57af9028348a91008
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu May 18 00:43:20 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu May 18 00:43:20 2017 +0200

lvconvert: fix indent and typo in last commit

---
 lib/metadata/raid_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 99fe275..d913301 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5871,8 +5871,8 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			seg_flag = SEG_RAID5_N;
 
 		else if (seg_is_any_raid5(seg_from) &&
-		    segtype_is_raid4(*segtype) &&
-		    !segtype_is_raid5_n(*segtype))
+			 segtype_is_raid4(*segtype) &&
+			 !segtype_is_raid5_n(*segtype))
 			seg_flag = SEG_RAID5_N;
 
 		else if (segtype_is_raid10(*segtype)) {
@@ -6071,7 +6071,7 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	    !is_same_level(seg_from->segtype, *segtype_to)) { /* Prompt here for takeover */
 		const char *basic_fmt = "Are you sure you want to convert %s LV %s";
 		const char *type_fmt = " to %s type";
-		const char *question_fmt = " to %s type";
+		const char *question_fmt = "? [y/n]: ";
 		char *fmt;
 		size_t sz = strlen(basic_fmt) + ((seg_from->segtype == *segtype_to) ? 0 : strlen(type_fmt)) + strlen(question_fmt) + 1;
 


