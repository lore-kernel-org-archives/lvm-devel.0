From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 20 Jan 2010 13:19:41 -0500
Subject: [PATCH 2/3] Remove useless memory allocation for pv->vg_name in _alloc_pv().
In-Reply-To: <1264011582-11548-2-git-send-email-dwysocha@redhat.com>
References: <1264011582-11548-1-git-send-email-dwysocha@redhat.com>
	<1264011582-11548-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1264011582-11548-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

All this seems to do is provide a memory leak so remove it.
The only caller of _alloc_pv() later explicitly sets
pv->vg_name = fmt->orphan_vg_name so clearly this allocation
should be removed.  I also saw no where in the code where
strncpy was used to assign pv->vg_name - only direct assignments
and strdup's.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f464cf8..a03194e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1444,11 +1444,6 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
 	if (!pv)
 		return_NULL;
 
-	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN))) {
-		dm_pool_free(mem, pv);
-		return NULL;
-	}
-
 	pv->pe_size = 0;
 	pv->pe_start = 0;
 	pv->pe_count = 0;
-- 
1.6.0.6


