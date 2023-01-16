From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:12 +0000 (GMT)
Subject: main - vdo: check memory only in non critical section
Message-ID: <20230116113912.EDD713858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=773b88e028ab2965a8c185f5f2147334f8f2bbfd
Commit:        773b88e028ab2965a8c185f5f2147334f8f2bbfd
Parent:        f486eb60d5cfb72f084b9e2c02e4dc962f26bb69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 10 21:12:22 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:38 2023 +0100

vdo: check memory only in non critical section

When we are actually resizing VDO device - we need to check size only in
non-critical section - otherwise we are checking
---
 lib/vdo/vdo.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index 9efb424f0..d2d14d146 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -23,6 +23,7 @@
 #include "lib/metadata/metadata.h"
 #include "lib/metadata/lv_alloc.h"
 #include "lib/metadata/segtype.h"
+#include "lib/mm/memlock.h"
 #include "base/memory/zalloc.h"
 
 static const char _vdo_module[] = MODULE_NAME_VDO;
@@ -374,7 +375,8 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!check_vdo_constrains(cmd, seg->lv->size, seg_lv(seg, 0)->size, &seg->vdo_params))
+	if (!critical_section() &&
+	    !check_vdo_constrains(cmd, seg->lv->size, get_vdo_pool_virtual_size(seg), &seg->vdo_params))
 		return_0;
 
 	if (!(vdo_pool_name = dm_build_dm_name(mem, seg->lv->vg->name, seg->lv->name, lv_layer(seg->lv))))

