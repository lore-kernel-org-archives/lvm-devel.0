From: Milan Broz <mbroz@redhat.com>
Date: Wed, 25 Mar 2009 18:53:54 +0100
Subject: [PATCH] fix dm debug pool issues
In-Reply-To: <20090325173303.GL13664@agk.fab.redhat.com>
References: <49CA64CA.6010708@redhat.com>
	<20090325173303.GL13664@agk.fab.redhat.com>
Message-ID: <49CA6FB2.4090504@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

and next obvious problem with pool data caught by pool debug:

- second iteration in loop operates on non-existing object here

Signed-off-by: Milan Broz <mbroz@redhat.com>

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2661e0c..991d63c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -611,12 +611,12 @@ static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_are
 	if (!parallel_areas)
 		return 1;
 
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
-		return 0;
-	}
-
 	dm_list_iterate_items(spvs, parallel_areas) {
+		if (!dm_pool_begin_object(mem, 256)) {
+			log_error("dm_pool_begin_object failed");
+			return 0;
+		}
+
 		dm_list_iterate_items(pvl, &spvs->pvs) {
 			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
 				log_error("dm_pool_grow_object failed");



