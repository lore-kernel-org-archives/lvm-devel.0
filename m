From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:55 +0000 (UTC)
Subject: master - cleanup: shorter code
Message-ID: <20141030230055.97BDE60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe245d78ff603dd798b719854ee8d900f858779d
Commit:        fe245d78ff603dd798b719854ee8d900f858779d
Parent:        888b21e9bd10d70154fb361359a2342aa56af27a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 13:04:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

cleanup: shorter code

---
 lib/metadata/pool_manip.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index d1b4497..c7c07e5 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -533,12 +533,11 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.read_ahead = read_ahead,
 		.stripe_size = stripe_size,
 		.stripes = stripes,
-		.zero = 1,
+		.tags = DM_LIST_HEAD_INIT(lvc.tags),
 		.temporary = 1,
+		.zero = 1,
 	};
 
-	dm_list_init(&lvc.tags);
-
 	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
 					      pool_lv->vg->extent_size)))
 		return_0;
@@ -574,12 +573,11 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		.pvh = pvh ? : &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
-		.zero = 1,
+		.tags = DM_LIST_HEAD_INIT(lp.tags),
 		.temporary = 1,
+		.zero = 1,
 	};
 
-	dm_list_init(&lp.tags);
-
 	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
 		return_0;
 


