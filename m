From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:49:00 +0000 (UTC)
Subject: master - thin: add alloc_pool_metadata
Message-ID: <20121119134900.CE5001698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b78609686399ee01a53d8a2e8685cd05389d8cc9
Commit:        b78609686399ee01a53d8a2e8685cd05389d8cc9
Parent:        f4137640f60af5377615a1b9e50238b593cf272b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 13:37:36 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:38:17 2012 +0100

thin: add alloc_pool_metadata

Since our api call is not yet powerfull enough,
use this wrapper to preset options.
---
 tools/toollib.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    5 +++++
 2 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index c3c6381..ba1ba94 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1650,6 +1650,50 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr,
 	return 1;
 }
 
+struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
+					   alloc_policy_t alloc,
+					   const char *name,
+					   struct dm_list *pvh,
+					   uint32_t read_ahead,
+					   uint32_t stripes,
+					   uint32_t stripe_size,
+					   uint64_t size)
+{
+	struct logical_volume *metadata_lv;
+	struct lvcreate_params lvc;
+
+	/* FIXME: Make lvm2api usable */
+	memset(&lvc, 0, sizeof(lvc));
+
+	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
+					      pool_lv->vg->extent_size)))
+		return_0;
+
+	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
+		return_0;
+
+	dm_list_init(&lvc.tags);
+
+	/* FIXME: allocate properly space for metadata_lv */
+	lvc.activate = CHANGE_ALY;
+	lvc.alloc = alloc;
+	lvc.lv_name = name;
+	lvc.major = -1;
+	lvc.minor = -1;
+	lvc.permission = LVM_READ | LVM_WRITE;
+	lvc.pvh = pvh;
+	lvc.read_ahead = read_ahead;
+	lvc.stripe_size = stripe_size;
+	lvc.stripes = stripes;
+	lvc.vg_name = pool_lv->vg->name;
+	lvc.zero = 1;
+
+	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
+		return_0;
+
+	return metadata_lv;
+}
+
 /*
  * Generic stripe parameter checks.
  */
diff --git a/tools/toollib.h b/tools/toollib.h
index 09071b3..80c01fd 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -120,6 +120,11 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr,
 		       uint32_t data_extents, uint32_t extent_size,
 		       uint32_t *chunk_size, thin_discards_t *discards,
 		       uint64_t *pool_metadata_size);
+struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
+					   alloc_policy_t alloc, const char *name,
+					   struct dm_list *pvh, uint32_t read_ahead,
+					   uint32_t stripes, uint32_t stripe_size,
+					   uint64_t size);
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 


