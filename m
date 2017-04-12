From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 12 Apr 2017 13:34:43 -0400
Subject: master - lvconvert: better message on --regionsize
Message-ID: <201704121734.v3CHYhnt030072@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51a31dbd79e6fd9dc289250f875badd9afbff428
Commit:        51a31dbd79e6fd9dc289250f875badd9afbff428
Parent:        f5b0697c0535a532aa81bcf78e59fb6d7cdd9fe0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 12 19:34:18 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 12 19:34:18 2017 +0200

lvconvert: better message on --regionsize

Enhance message on "lvconvert --regionsize size RaidLV".
in case the regionsize does not change and return error.
---
 lib/metadata/raid_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b58ba2d..d16d49f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5792,9 +5792,10 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 		return_0;
 
 	if (region_size == seg->region_size) {
-		log_print_unless_silent("Region size wouldn't change on %s LV %s.",
-					lvseg_name(seg), display_lvname(lv));
-		return 1;
+		log_error("Region size is already %s on %s LV %s.",
+			  display_size(lv->vg->cmd, region_size),
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
 	}
 
 	if (!_check_region_size_constraints(lv, seg->segtype, region_size, seg->stripe_size))


