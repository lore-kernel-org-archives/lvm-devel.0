From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:44 +0000 (UTC)
Subject: master - cleanup: more readable code
Message-ID: <20151117180144.635B160D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e71d3fbde344c26f8301dbd9550a110d5bc7ac4
Commit:        6e71d3fbde344c26f8301dbd9550a110d5bc7ac4
Parent:        d8049dd17a50b704edea69c968305aee732cb256
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 13:15:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

cleanup: more readable code

Simplify if() expression.
Rename 'this' to 'vg'..
---
 lib/cache/lvmetad.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index d300d39..dced80a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1187,16 +1187,17 @@ struct _lvmetad_pvscan_baton {
 static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 {
 	struct _lvmetad_pvscan_baton *b = baton;
-	struct volume_group *this;
+	struct volume_group *vg;
 
-	if (!(this = mda_is_ignored(mda) ? NULL : mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1)))
+	if (mda_is_ignored(mda) ||
+	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1)))
 		return 1;
 
 	/* FIXME Also ensure contents match etc. */
-	if (!b->vg || this->seqno > b->vg->seqno)
-		b->vg = this;
+	if (!b->vg || vg->seqno > b->vg->seqno)
+		b->vg = vg;
 	else if (b->vg)
-		release_vg(this);
+		release_vg(vg);
 
 	return 1;
 }


