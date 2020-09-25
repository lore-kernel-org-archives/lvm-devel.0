From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:04 +0000 (GMT)
Subject: master - thin: improve error message
Message-ID: <20200925210704.E77DA385782E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b22e3808772601725c0e253f4aa5bed24905271
Commit:        8b22e3808772601725c0e253f4aa5bed24905271
Parent:        ef59c83f2df61b0f0263b0e32dac66eb0cb75488
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 22:42:22 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

thin: improve error message

Add more info, explaing why the suspend of thin snapshot origin was omitted.
---
 lib/thin/thin.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d759b76e4..9c4bfb39c 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -361,8 +361,11 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				if (!lv_thin_pool_transaction_id(seg->lv, &transaction_id))
 					return_0; /* Thin pool should exist and work */
 				if ((transaction_id + 1) != seg->transaction_id) {
-					log_error("Can't create snapshot %s as origin %s is not suspended.",
-						  lmsg->u.lv->name, origin->name);
+					log_error("Omitting suspend of thin snapshot origin %s with expected "
+						  "transaction_id " FMTu64 ", but active pool has " FMTu64 ".",
+						  display_lvname(origin),
+						  !seg->transaction_id ? 0 : seg->transaction_id - 1,
+						  transaction_id);
 					return 0;
 				}
 			}


