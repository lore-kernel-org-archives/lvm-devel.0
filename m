From: Andy Grover <grover@fedoraproject.org>
Date: Mon, 17 Dec 2012 22:14:59 +0000 (UTC)
Subject: master - lvm2app: No special behavior for 0 for max_snap_size in lvm_lv_snapshot()
Message-ID: <20121217221459.E804735F0@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86e528c6677b4eff40df5c2424fdb588effdc73e
Commit:        86e528c6677b4eff40df5c2424fdb588effdc73e
Parent:        69099e7ef57eb2d39da836a5466196ec05123ffb
Author:        Andy Grover <agrover@redhat.com>
AuthorDate:    Mon Dec 17 14:14:38 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Mon Dec 17 14:14:38 2012 -0800

lvm2app: No special behavior for 0 for max_snap_size in lvm_lv_snapshot()

It isn't possible to choose a sane default for snapshot size, so just
play it straight and use the passed size instead of adding special
behavior for 0.

Also revert change to Python lib, size parameter must be supplied.

Signed-off-by: Andy Grover <agrover@redhat.com>
---
 liblvm/lvm_lv.c |   11 +----------
 python/liblvm.c |    4 ++--
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index a02e68d..91948a6 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -326,16 +326,7 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
 	if (!vg_check_write_mode(lv->vg))
 		return NULL;
 
-	/* Determine the correct size */
-	if (0 == max_snap_size){
-		size = lv->size;
-	} else {
-		size = max_snap_size >> SECTOR_SHIFT;
-
-		if (size > lv->size) {
-			size = lv->size;
-		}
-	}
+	size = max_snap_size >> SECTOR_SHIFT;
 
 	if (!(extents = extents_from_size(lv->vg->cmd, size,
 					  lv->vg->extent_size))) {
diff --git a/python/liblvm.c b/python/liblvm.c
index 4db507c..906825e 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1317,12 +1317,12 @@ static PyObject *
 liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
 	const char *vgname;
-	uint64_t size = 0;
+	uint64_t size;
 	lvobject *lvobj;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s|l", &vgname, &size)) {
+	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
 		return NULL;
 	}
 


