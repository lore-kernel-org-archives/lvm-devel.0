From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:40 +0000 (UTC)
Subject: dev-dct-process-latest - allocation: use vg memory pool
Message-ID: <20140922153740.7E86E60D7D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15ba2afdc2d70ee21c2599f0d51a413f0a7afa9b
Commit:        15ba2afdc2d70ee21c2599f0d51a413f0a7afa9b
Parent:        3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 19:00:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:39:58 2014 +0200

allocation: use vg memory pool

Looks like forgotten memory allocation related to VG used cmd mem pool.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8c1bd83..12585ef 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3083,7 +3083,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 	if (alloc >= ALLOC_INHERIT)
 		alloc = vg->alloc;
 
-	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc, approx_alloc,
+	if (!(ah = _alloc_init(vg->cmd, vg->vgmem, segtype, alloc, approx_alloc,
 			       lv ? lv->le_count : 0, extents, mirrors, stripes, log_count,
 			       vg->extent_size, region_size,
 			       parallel_areas)))


