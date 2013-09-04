From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  4 Sep 2013 15:07:02 -0500
Subject: [PATCH 1/4] python-lvm: Correct names
Message-ID: <1378325225-16335-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The existing names do not follow accepted guidelines.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index a9de817..42a327e 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1846,7 +1846,7 @@ static PyMethodDef _liblvm_pvseg_methods[] = {
 
 static PyTypeObject _LibLVMvgType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-	.tp_name = "liblvm.Liblvm_vg",
+	.tp_name = "lvm.Liblvm_vg",
 	.tp_basicsize = sizeof(vgobject),
 	.tp_new = PyType_GenericNew,
 	.tp_dealloc = (destructor)liblvm_vg_dealloc,
@@ -1857,7 +1857,7 @@ static PyTypeObject _LibLVMvgType = {
 
 static PyTypeObject _LibLVMlvType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-	.tp_name = "liblvm.Liblvm_lv",
+	.tp_name = "lvm.Liblvm_lv",
 	.tp_basicsize = sizeof(lvobject),
 	.tp_new = PyType_GenericNew,
 	.tp_dealloc = (destructor)liblvm_lv_dealloc,
@@ -1868,7 +1868,7 @@ static PyTypeObject _LibLVMlvType = {
 
 static PyTypeObject _LibLVMpvlistType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-	.tp_name = "liblvm.Liblvm_pvlist",
+	.tp_name = "lvm.Liblvm_pvlist",
 	.tp_basicsize = sizeof(pvslistobject),
 	.tp_new = PyType_GenericNew,
 	.tp_dealloc = (destructor)_liblvm_pvlist_dealloc,
@@ -1879,7 +1879,7 @@ static PyTypeObject _LibLVMpvlistType = {
 
 static PyTypeObject _LibLVMpvType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-	.tp_name = "liblvm.Liblvm_pv",
+	.tp_name = "lvm.Liblvm_pv",
 	.tp_basicsize = sizeof(pvobject),
 	.tp_new = PyType_GenericNew,
 	.tp_dealloc = (destructor)_liblvm_pv_dealloc,
@@ -1890,7 +1890,7 @@ static PyTypeObject _LibLVMpvType = {
 
 static PyTypeObject _LibLVMlvsegType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-	.tp_name = "liblvm.Liblvm_lvseg",
+	.tp_name = "lvm.Liblvm_lvseg",
 	.tp_basicsize = sizeof(lvsegobject),
 	.tp_new = PyType_GenericNew,
 	.tp_dealloc = (destructor)_liblvm_lvseg_dealloc,
@@ -1901,7 +1901,7 @@ static PyTypeObject _LibLVMlvsegType = {
 
 static PyTypeObject _LibLVMpvsegType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-	.tp_name = "liblvm.Liblvm_pvseg",
+	.tp_name = "lvm.Liblvm_pvseg",
 	.tp_basicsize = sizeof(pvsegobject),
 	.tp_new = PyType_GenericNew,
 	.tp_dealloc = (destructor)_liblvm_pvseg_dealloc,
@@ -1952,7 +1952,7 @@ PyMODINIT_FUNC initlvm(void)
 				    LVM_THIN_DISCARDS_PASSDOWN) < 0)
 		return;
 
-	if ((_LibLVMError = PyErr_NewException("Liblvm._LibLVMError", NULL, NULL))) {
+	if ((_LibLVMError = PyErr_NewException("lvm.LibLVMError", NULL, NULL))) {
 		/* Each call to PyModule_AddObject decrefs it; compensate: */
 		Py_INCREF(_LibLVMError);
 		Py_INCREF(_LibLVMError);
-- 
1.8.2.1


