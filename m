From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Dec 2012 10:26:47 +0000 (UTC)
Subject: master - thin: fix test for dicards ignore settings
Message-ID: <20121211102647.F2E2C1465@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17be6d521008f4433dc4dc76464af9f993491745
Commit:        17be6d521008f4433dc4dc76464af9f993491745
Parent:        ed65860861edcb5cd41656b05833defef5d592d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 10 10:22:48 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 11 11:26:19 2012 +0100

thin: fix test for dicards ignore settings

Arghh, this was bad last-minute shortening of if() expression
in the commit 1ef98310187a7.

dm_tree_node_set_thin_pool_discard() must not run in the same
expression as check for non-power-2 discard, otherwise
there are 2 calls for dm_tree_node_set_thin_pool_discard
and whole setting of discards is missinterpretted.

In-relase fix it by using proper parentheses {}.
---
 lib/thin/thin.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d7c45ca..14eb096 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -289,11 +289,11 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		/* FIXME: Check whether underlying dev supports discards */
 		if (((!(attr & THIN_FEATURE_DISCARDS_NON_POWER_2) &&
 		      (seg->chunk_size & (seg->chunk_size - 1))) ||
-		     (seg->discards == THIN_DISCARDS_IGNORE)) &&
-		    !dm_tree_node_set_thin_pool_discard(node, 1, 0))
-			return_0;
-		else if (!dm_tree_node_set_thin_pool_discard(node, 0,
-							     (seg->discards == THIN_DISCARDS_NO_PASSDOWN)))
+		     (seg->discards == THIN_DISCARDS_IGNORE))) {
+			if (!dm_tree_node_set_thin_pool_discard(node, 1, 0))
+				return_0;
+		} else if (!dm_tree_node_set_thin_pool_discard(node, 0,
+							       (seg->discards == THIN_DISCARDS_NO_PASSDOWN)))
 			return_0;
 	} else if (seg->discards != THIN_DISCARDS_IGNORE)
 		log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "


