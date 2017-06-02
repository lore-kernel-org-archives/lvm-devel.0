From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 2 Jun 2017 08:31:40 -0400
Subject: master - lvconvert: choose direct path to desired raid level
Message-ID: <201706021231.v52CVeYv013719@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3217e0cfeaed313332a0b69437ee87ca1f4b9e5e
Commit:        3217e0cfeaed313332a0b69437ee87ca1f4b9e5e
Parent:        c98a25aab1659a5640ac473517bb6af97d696588
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jun 2 14:30:57 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jun 2 14:30:57 2017 +0200

lvconvert: choose direct path to desired raid level

Remove superfluous raid5_n interim LV type from raid4 -> raid10 conversion.

Resolves: rhbz1458006
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 80541fd..8c9069c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5897,7 +5897,7 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 				return 0;
 			}
 
-			seg_flag = seg_is_raid5_n(seg_from) ? SEG_RAID0_META : SEG_RAID5_N;
+			seg_flag = SEG_RAID0_META;
 
 		} else if (segtype_is_any_raid6(*segtype)) {
 			if (seg_from->area_count < 4) {


