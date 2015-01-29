From: Lidong Zhong <lzhong@suse.com>
Date: Thu, 29 Jan 2015 15:16:53 +0800
Subject: [PATCH] metadata: remove mdas variable
Message-ID: <1422515813-9565-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This variable is not ever used in pvcreate_vol function

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 lib/metadata/metadata.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 465eb84..3304631 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1620,7 +1620,6 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 {
 	struct physical_volume *pv = NULL;
 	struct device *dev;
-	struct dm_list mdas;
 	struct pvcreate_params default_pp;
 	char buffer[64] __attribute__((aligned(8)));
 
@@ -1656,8 +1655,6 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 		goto bad;
 	}
 
-	dm_list_init(&mdas);
-
 	if (!(pv = pv_create(cmd, dev, pp->size, pp->data_alignment,
 			     pp->data_alignment_offset, pp->labelsector,
 			     pp->pvmetadatacopies, pp->pvmetadatasize,
-- 
1.8.1.4


