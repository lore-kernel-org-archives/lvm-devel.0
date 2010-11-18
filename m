From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:23 +0100
Subject: [PATCH 09/11] Remove useless mdas parameter in code creating new PVs.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-10-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/metadata/metadata.c |    2 --
 tools/vgconvert.c       |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index be1e7c5..c9d58e2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1434,7 +1434,6 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 {
 	struct physical_volume *pv;
 	struct device *dev;
-	struct dm_list mdas;
 	struct pvcreate_params default_pp;
 	char buffer[64] __attribute__((aligned(8)));
 
@@ -1466,7 +1465,6 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 		goto error;
 	}
 
-	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
 			     pp->data_alignment, pp->data_alignment_offset,
 			     pp->pe_start, pp->extent_count, pp->extent_size,
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 2043500..d2f2d66 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -23,7 +23,6 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	struct logical_volume *lv;
 	struct lv_list *lvl;
 	uint64_t size = 0;
-	struct dm_list mdas;
 	int pvmetadatacopies = 0;
 	uint64_t pvmetadatasize = 0;
 	uint64_t pe_end = 0, pe_start = 0;
@@ -122,7 +121,6 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv)
 		    + pe_start - 1;
 
-		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
 				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
-- 
1.7.3.2


