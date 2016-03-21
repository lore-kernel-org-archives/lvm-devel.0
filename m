From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Mar 2016 13:40:35 +0000 (UTC)
Subject: master - metadata: use own mem pool to report PV device mismatch in VG
Message-ID: <20160321134035.C7E3F60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f231bdb20bdc885460dfc49db744147bb1bc90da
Commit:        f231bdb20bdc885460dfc49db744147bb1bc90da
Parent:        03b0a786403ad1762bfbbe354756a9b83ee6629c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 21 14:38:49 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 21 14:39:11 2016 +0100

metadata: use own mem pool to report PV device mismatch in VG

---
 lib/metadata/metadata.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 86fb7cd..2c5ede5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4582,9 +4582,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 #define DEV_LIST_DELIM ", "
 
-static int _check_devs_used_correspond_with_lv(struct dm_list *list, struct logical_volume *lv)
+static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_list *list, struct logical_volume *lv)
 {
-	struct dm_pool *mem = lv->vg->vgmem;
 	struct device_list *dl;
 	int found_inconsistent = 0;
 	struct device *dev;
@@ -4657,6 +4656,7 @@ bad:
 
 static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 {
+	struct dm_pool *mem;
 	char vgid[ID_LEN + 1];
 	struct pv_list *pvl;
 	struct lv_list *lvl;
@@ -4689,10 +4689,17 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 	}
 
 	if (found_inconsistent) {
+		if (!(mem = dm_pool_create("vg_devs_check", 1024)))
+			return_0;
+
 		dm_list_iterate_items(lvl, &vg->lvs) {
-			if (!_check_devs_used_correspond_with_lv(list, lvl->lv))
+			if (!_check_devs_used_correspond_with_lv(mem, list, lvl->lv)) {
+				dm_pool_destroy(mem);
 				return_0;
+			}
 		}
+
+		dm_pool_destroy(mem);
 	}
 
 	return 1;


