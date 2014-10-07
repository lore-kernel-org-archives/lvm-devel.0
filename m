From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 08:20:29 +0000 (UTC)
Subject: master - cleanup: dont hide pv_dev declaration from pv
Message-ID: <20141007082029.3CCB4602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9810f8aac7c0e38bd6cb88a45140bb41d52cd5b5
Commit:        9810f8aac7c0e38bd6cb88a45140bb41d52cd5b5
Parent:        b836525d9cc267a04881b82935a6a045753631bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 10:17:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 10:19:32 2014 +0200

cleanup: dont hide pv_dev declaration from pv

Just skip using local vars here...
---
 lib/metadata/metadata.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 681c2dd..3e5bd5d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1778,12 +1778,9 @@ struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			       const char *pv_name)
 {
 	struct pv_list *pvl;
-	struct device *pv_dev, *cached_dev;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		pv_dev = pvl->pv->dev;
-		cached_dev = dev_cache_get(pv_name, vg->cmd->filter);
-		if (!pv_dev) {
+		if (!pvl->pv->dev) {
 			/*
 			 * pv_dev can't be NULL here!
 			 * We have to catch this situation earlier in the
@@ -1800,10 +1797,10 @@ struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			 * handled earlier in the code in that case.
 			 */
 			log_error(INTERNAL_ERROR "find_pv_in_vg: PV that is not "
-				  "bound to any existing device found");
+				  "bound to any existing device found.");
 			return NULL;
 		}
-		if (pv_dev == cached_dev)
+		if (pvl->pv->dev == dev_cache_get(pv_name, vg->cmd->filter))
 			return pvl;
 	}
 


