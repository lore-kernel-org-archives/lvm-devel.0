From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:49 +0000 (GMT)
Subject: stable-2.02 - thin: improve error message
Message-ID: <20201016191149.CF49E396EC72@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a2ada80cb9f8982c91772a0bb4309027dcb8b2b
Commit:        3a2ada80cb9f8982c91772a0bb4309027dcb8b2b
Parent:        22b256a09ae6a7def0228a18a940b3f6876c3211
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 22:42:22 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

thin: improve error message

Add more info, explaing why the suspend of thin snapshot origin was omitted.
---
 lib/thin/thin.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index b6eb3aaae..69317a8e5 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -360,8 +360,11 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
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


