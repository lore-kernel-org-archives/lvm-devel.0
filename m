From: Andy Grover <grover@fedoraproject.org>
Date: Thu,  6 Dec 2012 00:33:09 +0000 (UTC)
Subject: master - Fix Py_BuildValue for i386
Message-ID: <20121206003309.79EB9A0C59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ec6a59dcf2c1c2788d12bd4374c6dbb5cfb8e36
Commit:        1ec6a59dcf2c1c2788d12bd4374c6dbb5cfb8e36
Parent:        383575525916d4cafb1c8396c95a40be539d1451
Author:        James Antill <james.antill@redhat.com>
AuthorDate:    Wed Dec 5 16:31:30 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Wed Dec 5 16:31:50 2012 -0800

Fix Py_BuildValue for i386

see https://bugzilla.redhat.com/show_bug.cgi?id=881989

Signed-off-by: James Antill <james.antill@redhat.com>
Signed-off-by: Andy Grover <agrover@redhat.com>
---
 python/liblvm.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 831493e..6ccc5ba 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -564,7 +564,7 @@ liblvm_lvm_vg_get_seqno(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_seqno(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_seqno(self->vg));
 }
 
 static PyObject *
@@ -572,7 +572,7 @@ liblvm_lvm_vg_get_size(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_size(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_size(self->vg));
 }
 
 static PyObject *
@@ -580,7 +580,7 @@ liblvm_lvm_vg_get_free_size(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_free_size(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_free_size(self->vg));
 }
 
 static PyObject *
@@ -588,7 +588,7 @@ liblvm_lvm_vg_get_extent_size(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_extent_size(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_extent_size(self->vg));
 }
 
 static PyObject *
@@ -596,7 +596,7 @@ liblvm_lvm_vg_get_extent_count(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_extent_count(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_extent_count(self->vg));
 }
 
 static PyObject *
@@ -604,7 +604,7 @@ liblvm_lvm_vg_get_free_extent_count(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_free_extent_count(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_free_extent_count(self->vg));
 }
 
 /* Builds a python tuple ([string|number], bool) from a struct lvm_property_value */
@@ -755,7 +755,7 @@ liblvm_lvm_vg_get_pv_count(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_pv_count(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_pv_count(self->vg));
 }
 
 static PyObject *
@@ -763,7 +763,7 @@ liblvm_lvm_vg_get_max_pv(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_max_pv(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_max_pv(self->vg));
 }
 
 static PyObject *
@@ -771,7 +771,7 @@ liblvm_lvm_vg_get_max_lv(vgobject *self)
 {
 	VG_VALID(self);
 
-	return Py_BuildValue("l", lvm_vg_get_max_lv(self->vg));
+	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_max_lv(self->vg));
 }
 
 static PyObject *
@@ -1133,7 +1133,7 @@ liblvm_lvm_lv_get_size(lvobject *self)
 {
 	LV_VALID(self);
 
-	return Py_BuildValue("l", lvm_lv_get_size(self->lv));
+	return Py_BuildValue("K", (unsigned long long)lvm_lv_get_size(self->lv));
 }
 
 static PyObject *
@@ -1344,7 +1344,7 @@ liblvm_lvm_pv_get_mda_count(pvobject *self)
 {
 	PV_VALID(self);
 
-	return Py_BuildValue("l", lvm_pv_get_mda_count(self->pv));
+	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_mda_count(self->pv));
 }
 
 static PyObject *
@@ -1367,7 +1367,7 @@ liblvm_lvm_pv_get_dev_size(pvobject *self)
 {
 	PV_VALID(self);
 
-	return Py_BuildValue("l", lvm_pv_get_dev_size(self->pv));
+	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_dev_size(self->pv));
 }
 
 static PyObject *
@@ -1375,7 +1375,7 @@ liblvm_lvm_pv_get_size(pvobject *self)
 {
 	PV_VALID(self);
 
-	return Py_BuildValue("l", lvm_pv_get_size(self->pv));
+	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_size(self->pv));
 }
 
 static PyObject *
@@ -1383,7 +1383,7 @@ liblvm_lvm_pv_get_free(pvobject *self)
 {
 	PV_VALID(self);
 
-	return Py_BuildValue("l", lvm_pv_get_free(self->pv));
+	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_free(self->pv));
 }
 
 static PyObject *


