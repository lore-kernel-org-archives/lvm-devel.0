From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:40 +0000 (UTC)
Subject: master - python-lvm: Change snapshot call impl.
Message-ID: <20130702192640.4D8C560DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8882480083f9b4f769cc8756a2f641ae0452040d
Commit:        8882480083f9b4f769cc8756a2f641ae0452040d
Parent:        49e3eecc33dbe0a47d8dcdbf225ddd52a8a6b75d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Jun 6 16:41:35 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Change snapshot call impl.

Using the new object parameter creation to create the snapshot.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index e631ab1..e696a81 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1582,23 +1582,33 @@ liblvm_lvm_lv_list_lvsegs(lvobject *self)
 static PyObject *
 liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
-	const char *vgname;
-	uint64_t size;
+	const char *snap_name;
+	uint64_t size = 0;
 	lvobject *lvobj;
+	lv_create_params_t lvp = NULL;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
+	if (!PyArg_ParseTuple(args, "s|K", &snap_name, &size)) {
 		return NULL;
 	}
 
 	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
 		return NULL;
 
-	if ((lvobj->lv = lvm_lv_snapshot(self->lv, vgname, size)) == NULL) {
+	lvobj->parent_vgobj = NULL;
+
+	lvp = lvm_lv_params_create_snapshot(self->lv, snap_name, size);
+	if (lvp) {
+		if ((lvobj->lv = lvm_lv_create(lvp)) == NULL) {
+			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+			Py_DECREF(lvobj);
+			return NULL;
+		}
+	} else {
 		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-		Py_DECREF(lvobj);
-		return NULL;
+						Py_DECREF(lvobj);
+						return NULL;
 	}
 
 	lvobj->parent_vgobj = self->parent_vgobj;


