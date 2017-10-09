From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 9 Oct 2017 07:55:55 -0400
Subject: master - raid: return previous reshape space allocation properly
Message-ID: <201710091155.v99BtttT004035@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=554a761db2acf2216eadf0279a390ac924038286
Commit:        554a761db2acf2216eadf0279a390ac924038286
Parent:        f005a6e7922d9a95eadfbd433714c80301eba794
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Oct 9 13:53:27 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Oct 9 13:55:01 2017 +0200

raid: return previous reshape space allocation properly

Fix returning previous allocation of reshape space.
---
 lib/metadata/raid_manip.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 885a1ca..691ff58 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1692,10 +1692,10 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum alloc_where *where_it_was)
 {
 	uint32_t total_reshape_len;
+	enum alloc_where where;
 	struct lv_segment *seg = first_seg(lv);
 
 	if ((total_reshape_len = _reshape_len_per_lv(lv))) {
-		enum alloc_where where;
 		/*
 		 * raid10:
 		 *
@@ -1743,9 +1743,11 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 			return_0;
 
 		lv->status &= ~LV_RESHAPE_DATA_OFFSET;
+	} else
+		where = alloc_none;
 
-	} else if (where_it_was)
-		*where_it_was = alloc_none;
+	if (where_it_was)
+		*where_it_was = where;
 
 	lv->status &= ~LV_RESHAPE;
 


