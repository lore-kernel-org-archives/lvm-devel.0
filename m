From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:55 +0000 (GMT)
Subject: stable-2.02 - thin: remove unneeded code test
Message-ID: <20201016191155.89B223857824@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=45121aafe9f7623b7ca26678a9fa8ff659aaf1b0
Commit:        45121aafe9f7623b7ca26678a9fa8ff659aaf1b0
Parent:        3094c423a0832c703406be3847d561226c19ea10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 27 02:20:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

thin: remove unneeded code test

Since we detect already transaction if before starting
to build dm tree - this extra check is a duplicate
that would only capture very tiny 'race' and we later
validate transaction_id with suspended snapshot origin.
---
 lib/thin/thin.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 69317a8e5..b7c80bcd2 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -264,8 +264,6 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
 	const struct logical_volume *origin;
-	struct lvinfo info;
-	uint64_t transaction_id = 0;
 	unsigned attr;
 	uint64_t low_water_mark;
 	int threshold;
@@ -350,24 +348,6 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			origin = first_seg(lmsg->u.lv)->origin;
 			/* Check if the origin is suspended */
-			if (origin && lv_info(cmd, origin, 1, &info, 0, 0) &&
-			    info.exists && !info.suspended) {
-				/* Origin is not suspended, but the transaction may have been
-				 * already transfered, so test for transaction_id and
-				 * allow to pass in the message for dmtree processing
-				 * so it will skip all messages later.
-				 */
-				if (!lv_thin_pool_transaction_id(seg->lv, &transaction_id))
-					return_0; /* Thin pool should exist and work */
-				if ((transaction_id + 1) != seg->transaction_id) {
-					log_error("Omitting suspend of thin snapshot origin %s with expected "
-						  "transaction_id " FMTu64 ", but active pool has " FMTu64 ".",
-						  display_lvname(origin),
-						  !seg->transaction_id ? 0 : seg->transaction_id - 1,
-						  transaction_id);
-					return 0;
-				}
-			}
 			log_debug_activation("Thin pool create_%s %s.", (!origin) ? "thin" : "snap", lmsg->u.lv->name);
 			if (!dm_tree_node_add_thin_pool_message(node,
 								(!origin) ? lmsg->type : DM_THIN_MESSAGE_CREATE_SNAP,


