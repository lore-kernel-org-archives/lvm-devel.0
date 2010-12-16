From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:25 +0100
Subject: [PATCH 17/20] Remove dead assignment in dev_manager_transient
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <56ef3120aa631c388eb13c8d0dae970dc44225e5.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'segh' is never read after this assignment - remove it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 0bc658b..f950ca3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -620,7 +620,7 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 
 	} while (next);
 
-	if ((segh = dm_list_next(&lv->segments, segh))) {
+	if (dm_list_next(&lv->segments, segh)) {
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
-- 
1.7.3.3


