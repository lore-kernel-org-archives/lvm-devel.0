From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 20 Jan 2010 13:19:42 -0500
Subject: [PATCH 3/3] Call _alloc_pv() inside _pv_read() and clean up error paths.
In-Reply-To: <1264011582-11548-3-git-send-email-dwysocha@redhat.com>
References: <1264011582-11548-1-git-send-email-dwysocha@redhat.com>
	<1264011582-11548-2-git-send-email-dwysocha@redhat.com>
	<1264011582-11548-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1264011582-11548-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should be consistent with pv constructors so call _alloc_pv()
here as we do from pv_create().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a03194e..054d716 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3021,29 +3021,30 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	if (label_sector && *label_sector)
 		*label_sector = label->sector;
 
-	if (!(pv = dm_pool_zalloc(pvmem, sizeof(*pv)))) {
+	pv = _alloc_pv(pvmem, dev);
+	if (!pv) {
 		log_error("pv allocation for '%s' failed", pv_name);
 		return NULL;
 	}
 
-	dm_list_init(&pv->tags);
-	dm_list_init(&pv->segments);
-
 	/* FIXME Move more common code up here */
 	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas,
 	      scan_label_only))) {
 		log_error("Failed to read existing physical volume '%s'",
 			  pv_name);
-		return NULL;
+		goto bad;
 	}
 
 	if (!pv->size)
-		return NULL;
+		goto bad;
 
 	if (!alloc_pv_segment_whole_pv(pvmem, pv))
-		return_NULL;
+		goto_bad;
 
 	return pv;
+bad:
+	_free_pv(pvmem, pv);
+	return NULL;
 }
 
 /* May return empty list */
-- 
1.6.0.6


