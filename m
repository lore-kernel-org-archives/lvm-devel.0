From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:26:18 -0400
Subject: master - cleanup: use last_seg
Message-ID: <201807082226.w68MQIPO015981@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d1c983122bc2a17bbfbac234f9a73ee9c27f161
Commit:        6d1c983122bc2a17bbfbac234f9a73ee9c27f161
Parent:        a55d4b6051ed2edecf14549b8fef437023e1e272
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 7 21:35:07 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:23:35 2018 +0200

cleanup: use last_seg

More readable code.
---
 lib/metadata/lv_manip.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b315a87..7674a3e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3149,9 +3149,8 @@ static int _allocate(struct alloc_handle *ah,
 	if (ah->alloc == ALLOC_CONTIGUOUS)
 		can_split = 0;
 
-	if (lv && !dm_list_empty(&lv->segments))
-		prev_lvseg = dm_list_item(dm_list_last(&lv->segments),
-				       struct lv_segment);
+	if (lv)
+		prev_lvseg = last_seg(lv);
 	/*
 	 * Build the sets of available areas on the pv's.
 	 */


