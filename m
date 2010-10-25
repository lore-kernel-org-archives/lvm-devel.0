From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:30 +0200
Subject: [PATCH 23/30] Using const config node
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <dec5e1ea32d6dec85bf528ab73bd09587eeb09ec.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/striped/striped.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 01fbc1e..44f9774 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -71,7 +71,7 @@ static int _striped_text_import_area_count(struct config_node *sn, uint32_t *are
 static int _striped_text_import(struct lv_segment *seg, const struct config_node *sn,
 			struct dm_hash_table *pv_hash)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 
 	if ((seg->area_count != 1) &&
 	    !get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
-- 
1.7.3.1


