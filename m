From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 15:46:27 -0400
Subject: master - raid: remove double minimum area check on takeover
Message-ID: <201704201946.v3KJkRMh013103@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c2fd133d7b690889ed4153853151db5b38eb060
Commit:        0c2fd133d7b690889ed4153853151db5b38eb060
Parent:        d8a63f446e159bbd34292962e4ad9e25ea00cb95
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 20 21:35:06 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 20 21:35:06 2017 +0200

raid: remove double minimum area check on takeover

---
 lib/metadata/raid_manip.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 77ca006..03e32c6 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5061,12 +5061,6 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		}
 	}
 
-	if (seg_is_any_raid5(seg) && segtype_is_any_raid6(new_segtype) && seg->area_count < 4) {
-		log_error("Minimum of 3 stripes needed for conversion from %s to %s.",
-			  lvseg_name(seg), new_segtype->name);
-		return 0;
-	}
-
 	if (seg_is_raid1(seg)) {
 		if (seg->area_count != 2) {
 			log_error("Can't convert %s LV %s to %s with != 2 legs.",


