From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 23 Sep 2020 12:59:33 +0000 (GMT)
Subject: master - vdo: allow passing renamed vdopool name to kernel
Message-ID: <20200923125933.51C44398E478@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50a37948b5b2245a8f5d7d78aa88fa0679dfe0e5
Commit:        50a37948b5b2245a8f5d7d78aa88fa0679dfe0e5
Parent:        7c19186271d3bf37412b7e7dcc271bc9b79f9f4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 13:20:28 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 23 13:20:28 2020 +0200

vdo: allow passing renamed vdopool name to kernel

Although kernel does not allow to load a new dm table
with renamed vdopool, at least make lvm2 code ready
it it every will get supported.
---
 device_mapper/all.h           | 1 +
 device_mapper/libdm-deptree.c | 3 ++-
 lib/vdo/vdo.c                 | 6 ++++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index df47d1a5a..1080d25ad 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -1019,6 +1019,7 @@ int dm_tree_node_add_integrity_target(struct dm_tree_node *node,
  */
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
+				const char *vdo_pool_name,
 				const char *data_uuid,
 				uint64_t data_size,
 				const struct dm_vdo_target_params *param);
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 2722a2c3b..653dd0959 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -4360,6 +4360,7 @@ int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
+				const char *vdo_pool_name,
 				const char *data_uuid,
 				uint64_t data_size,
 				const struct dm_vdo_target_params *vtp)
@@ -4381,7 +4382,7 @@ int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 		return_0;
 
 	seg->vdo_params = *vtp;
-	seg->vdo_name = node->name;
+	seg->vdo_name = vdo_pool_name;
 	seg->vdo_data_size = data_size;
 
 	node->props.send_messages = 2;
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index ab6d00825..c43a5dc26 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -362,19 +362,21 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 				     struct dm_tree_node *node, uint64_t len,
 				     uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	char *data_uuid;
+	char *vdo_pool_name, *data_uuid;
 
 	if (!seg_is_vdo_pool(seg)) {
 		log_error(INTERNAL_ERROR "Passed segment is not VDO pool.");
 		return 0;
 	}
+	if (!(vdo_pool_name = dm_build_dm_name(mem, seg->lv->vg->name, seg->lv->name, lv_layer(seg->lv))))
+		return_0;
 
 	if (!(data_uuid = build_dm_uuid(mem, seg_lv(seg, 0), lv_layer(seg_lv(seg, 0)))))
 		return_0;
 
 	/* VDO uses virtual size instead of its physical size */
 	if (!dm_tree_node_add_vdo_target(node, get_vdo_pool_virtual_size(seg),
-					 data_uuid, seg_lv(seg, 0)->size,
+					 vdo_pool_name, data_uuid, seg_lv(seg, 0)->size,
 					 &seg->vdo_params))
 		return_0;
 


