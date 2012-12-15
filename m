From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:07 +0000 (UTC)
Subject: master - cleanup: ignore return values
Message-ID: <20121215162507.0778CAAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ab43345051fe49b1d56771383feb65c408eaf9a
Commit:        8ab43345051fe49b1d56771383feb65c408eaf9a
Parent:        1b05438fcbb27ba425c369c0b9d4e641ccc1b970
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 18:58:18 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: ignore return values

These dm_snprintfs should not fail, since enough space is reserved.
So return intentionaly ignored.
---
 lib/cache/lvmetad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a636f43..3ce2804 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -618,7 +618,7 @@ static int _extract_mda(struct metadata_area *mda, void *baton)
 	if (!mda->ops->mda_export_text) /* do nothing */
 		return 1;
 
-	dm_snprintf(id, 32, "mda%d", b->i);
+	(void) dm_snprintf(id, 32, "mda%d", b->i);
 	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
 		return 0;
 	if (!mda->ops->mda_export_text(mda, b->cft, cn))
@@ -639,7 +639,7 @@ static int _extract_da(struct disk_locn *da, void *baton)
 	if (!da)
 		return 1;
 
-	dm_snprintf(id, 32, "da%d", b->i);
+	(void) dm_snprintf(id, 32, "da%d", b->i);
 	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
 		return 0;
 	if (!config_make_nodes(b->cft, cn, NULL,


