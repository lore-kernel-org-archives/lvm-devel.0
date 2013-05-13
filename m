From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 May 2013 13:30:10 -0400
Subject: [PATCH] metadata: fix bug that allowed PE alignment to be misaligned
Message-ID: <1368466210-6142-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The default PE alignment could be selected (via MAX()) even if it was
determined that the device's MD stripe width, or minimal_io_size or
optimal_io_size were not factors of the default PE alignment (either 64K
or the newer default of 1MB, etc).  This bug would manifest if the
default PE alignment was larger than the overriding hint that the
device provided (e.g. default of 1MB vs optimal_io_size of 768K).

This fixes a long standing regression since LVM2 2.02.74 (commit 4efb1d9c,  
"Update heuristic used for default and detected data alignment.")

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/metadata/metadata.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bde1cb0..357e849 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -86,7 +86,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG)) {
 		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
+			pv->pe_align = temp_pe_align;
 	}
 
 	/*
@@ -99,11 +99,11 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG)) {
 		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
+			pv->pe_align = temp_pe_align;
 
 		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
+			pv->pe_align = temp_pe_align;
 	}
 
 out:
-- 
1.7.1


