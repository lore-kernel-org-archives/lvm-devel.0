From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:37 +0000 (GMT)
Subject: main - vdo: use fixed size vdopool wrapper
Message-ID: <20230406114737.9452D385843A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8e6347ba3f59cbd2f7e92aa707543b90fa607a3
Commit:        e8e6347ba3f59cbd2f7e92aa707543b90fa607a3
Parent:        334117ee00aa6751ff7589b983497e1b7eee9d76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 6 14:52:59 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 11:06:04 2023 +0200

vdo: use fixed size vdopool wrapper

Instead of using size of 'empty header' in vdopool use fixed size 4K
for a 'wrappeing' vdo-pool device.

This fixes the issue when user tried to activate vdo-pool after
a conversion from vdo managed device with 'vgchange -ay' - where
this command activated all LVs with 'vdo-pool' wrapping device as well,
but this converted pool uses  0-length header.

This 4k size should usually prevent other tools like 'blkid' recognize
such device as anything - so it shouldn't cause any problems with
duplicate indentification of devices.
---
 lib/activate/dev_manager.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c4bd6ab7b..ec642f421 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3115,7 +3115,7 @@ static int _add_layer_target_to_dtree(struct dev_manager *dm,
 
 	/* Add linear mapping over layered LV */
 	/* From VDO layer expose ONLY vdo pool header, we would need to use virtual size otherwise */
-	if (!add_linear_area_to_dtree(dnode, lv_is_vdo_pool(lv) ? first_seg(lv)->vdo_pool_header_size : lv->size,
+	if (!add_linear_area_to_dtree(dnode, lv_is_vdo_pool(lv) ? 8 : lv->size,
 				      lv->vg->extent_size,
 				      lv->vg->cmd->use_linear_target,
 				      lv->vg->name, lv->name) ||

