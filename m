From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:37 +0100
Subject: [PATCH 05/23] Remove dead assignment in vgconvert_single
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <2bf1127a19c1b88a3a5d37701967d486b7b54371.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'pe_end' is not used - remove it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgconvert.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index acae0fc..7d1ee19 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -26,7 +26,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	struct dm_list mdas;
 	int pvmetadatacopies = 0;
 	uint64_t pvmetadatasize = 0;
-	uint64_t pe_end = 0, pe_start = 0;
+	uint64_t pe_start = 0;
 	struct pv_list *pvl;
 	int change_made = 0;
 	struct lvinfo info;
@@ -119,8 +119,6 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		existing_pv = pvl->pv;
 
 		pe_start = pv_pe_start(existing_pv);
-		pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv)
-		    + pe_start - 1;
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-- 
1.7.3.4


