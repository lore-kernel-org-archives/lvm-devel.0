From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:45 +0000 (UTC)
Subject: master - lvm2app: update to new lv_create_single API
Message-ID: <20141026173745.86C1F60282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=618d818c0d31bbfa1ed4af2e8954c8a4b53127af
Commit:        618d818c0d31bbfa1ed4af2e8954c8a4b53127af
Parent:        7916cae697aed7e9f8c286e4f9c6de3cb7ed5e88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 07:25:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

lvm2app: update to new lv_create_single API

lv_create_single is more type based.
---
 liblvm/lvm_lv.c |   25 +++++++++++--------------
 python/liblvm.c |   14 +++++---------
 2 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index f7f1596..49737d5 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -221,7 +221,6 @@ static int _lv_set_default_linear_params(struct cmd_context *cmd,
 	}
 
 	lp->stripes = 1;
-	lp->stripe_size = DEFAULT_STRIPESIZE * 2;
 
 	return 1;
 }
@@ -499,9 +498,7 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 				vg_t vg, const char *pool_name,
 				uint64_t extents, uint64_t meta_size)
 {
-	_lv_set_default_params(lp, vg, NULL, extents);
-
-	lp->pool_name = pool_name;
+	_lv_set_default_params(lp, vg, pool_name, extents);
 
 	lp->create_pool = 1;
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
@@ -625,8 +622,8 @@ static int _lv_set_thin_params(struct lvcreate_params *lp,
 }
 
 static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
-						 const char *snap_name,
-						 uint64_t max_snap_size)
+							 const char *snap_name,
+							 uint64_t max_snap_size)
 {
 	uint64_t size = 0;
 	uint64_t extents = 0;
@@ -652,24 +649,24 @@ static lv_create_params_t _lvm_lv_params_create_snapshot(const lv_t lv,
 
 	if (!size && !lv_is_thin_volume(lv) ) {
 		log_error("Origin is not thin, specify size of snapshot");
-					return NULL;
+		return NULL;
 	}
 
 	lvcp = dm_pool_zalloc(lv->vg->vgmem, sizeof (struct lvm_lv_create_params));
 	if (lvcp) {
 		lvcp->vg = lv->vg;
 		_lv_set_default_params(&lvcp->lvp, lv->vg, snap_name, extents);
-		lvcp->lvp.snapshot = 1;
-
 
 		if (size) {
-			lvcp->lvp.segtype = _get_segtype(lvcp->vg->cmd);
+			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "snapshot"))) {
+				log_error("Segtype snapshot not found.");
+				return NULL;
+			}
 			lvcp->lvp.chunk_size = 8;
+			lvcp->lvp.snapshot = 1;
 		} else {
-			lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "thin");
-
-			if (!lvcp->lvp.segtype) {
-				log_error(INTERNAL_ERROR "Segtype thin not found.");
+			if (!(lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "thin"))) {
+				log_error("Segtype thin not found.");
 				return NULL;
 			}
 
diff --git a/python/liblvm.c b/python/liblvm.c
index 094aec2..9983135 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -611,7 +611,10 @@ static PyObject *_liblvm_lvm_vg_close(vgobject *self)
 {
 	/* if already closed, don't reclose it */
 	if (self->vg) {
-		lvm_vg_close(self->vg);
+		if (lvm_vg_close(self->vg) == -1) {
+			PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+			return NULL;
+		}
 		self->vg = NULL;
 		self->libh_copy = NULL;
 	}
@@ -647,14 +650,7 @@ static PyObject *_liblvm_lvm_vg_remove(vgobject *self)
 		goto error;
 
 	/* Not much you can do with a vg that is removed so close it */
-	if (lvm_vg_close(self->vg) == -1)
-		goto error;
-
-	self->vg = NULL;
-
-	Py_INCREF(Py_None);
-
-	return Py_None;
+	return _liblvm_lvm_vg_close(self);
 
 error:
 	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());


