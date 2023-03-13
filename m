From: Yi Wang <wang.yi59@zte.com.cn>
Date: Mon, 13 Mar 2023 10:37:44 +0800
Subject: [PATCH] metadata: skip MDA_IGNORED flags PV write metadata
Message-ID: <20230313023744.57876-1-wang.yi59@zte.com.cn>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Long YunJian <long.yunjian@zte.com.cn>

If we set vgmetadatacopies value which less than PV available numbers in a VG,
and use pvmetadataignore default 0, vgcreate save metadata to all pvs, included those
set MDA_IGNORED flags PV. It is misleading into thinking that the set MDA_IGNORED PV
is still in use. It also influence vgcreate performance in lots of PV environment.
So, we add filter condition to avoid write metadata to those set MDA_IGNORED flags PV.

Signed-off-by: Long YunJian <long.yunjian@zte.com.cn>
Signed-off-by: Yi Wang <wang.yi59@zte.com.cn>
---
 lib/metadata/metadata.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 10af75665..7ca2e9f77 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3017,7 +3017,7 @@ int vg_write(struct volume_group *vg)
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		mda_dev = mda_get_device(mda);
 
-		if (mda->status & MDA_FAILED)
+		if (mda->status & MDA_FAILED || mda->status & MDA_IGNORED)
 			continue;
 
 		/*
-- 
2.31.1

