From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:34 +0100
Subject: [PATCH 02/23] Remove dead assignment
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <5ad58b8832a98a0d53fc939b89dbac3940521747.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Variables 'lv_total' and 'lv_capasity_total' are unused.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvscan.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/lvscan.c b/tools/lvscan.c
index 638d2f5..1f91d39 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -19,8 +19,6 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 			 void *handle __attribute__((unused)))
 {
 	struct lvinfo info;
-	int lv_total = 0;
-	uint64_t lv_capacity_total = 0;
 	int inkernel, snap_active = 1;
 	struct lv_segment *snap_seg = NULL;
 	percent_t snap_percent;     /* fused, fsize; */
@@ -66,10 +64,6 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 		  display_size(cmd, lv->size),
 		  get_alloc_string(lv->alloc));
 
-	lv_total++;
-
-	lv_capacity_total += lv->size;
-
 	return ECMD_PROCESSED;
 }
 
-- 
1.7.3.4


