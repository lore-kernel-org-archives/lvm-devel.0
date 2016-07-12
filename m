From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 12 Jul 2016 14:25:26 +0000 (UTC)
Subject: master - vgsplit: use dm_list_next()
Message-ID: <20160712142526.ED883607BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c32f96f277ae1a36509c15b411939f779580b264
Commit:        c32f96f277ae1a36509c15b411939f779580b264
Parent:        4ca55192e0347c0c5124f7f2d8c1c30aa4d57a43
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 12 16:25:06 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 12 16:25:12 2016 +0200

vgsplit: use dm_list_next()

---
 tools/vgsplit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 806dafe..909a786 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -46,7 +46,7 @@ static int _lv_tree_move(struct dm_list *lvh,
 
 	/* Update the list pointer refering to the item moving to @vg_to. */
 	if (lvh == *lvht)
-		*lvht = lvh->n;
+		*lvht = dm_list_next(lvh, lvh);
 
 	dm_list_move(&vg_to->lvs, lvh);
 	lv->vg = vg_to;


