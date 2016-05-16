From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 May 2016 19:37:38 +0000 (UTC)
Subject: master - python: move lvm_init
Message-ID: <20160516193738.F380D60EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ef152c07290c79f47a64b0fc81975ae52554919
Commit:        7ef152c07290c79f47a64b0fc81975ae52554919
Parent:        57e9df7dc535bcba6124fce814323b63c6a0d779
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 11 13:42:00 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 16 14:36:55 2016 -0500

python: move lvm_init

Only call lvm_init() when it's needed so that simply
loading the lvm python code in another program doesn't
make that program do lvm initialization.

The version call doesn't need a handle.

The garbage collection can just do lvm_quit to destroy
the command.  The next call that needs lvm_init will
do it first.
---
 python/liblvm.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 089abb3..1b3534e 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -93,6 +93,9 @@ static PyObject *_LibLVMError;
 
 #define LVM_VALID(ptr) \
 	do { \
+		if (!_libh) { \
+			_libh = lvm_init(NULL); \
+		} \
 		if (ptr && _libh) { \
 			if (ptr != _libh) { \
 				PyErr_SetString(PyExc_UnboundLocalError, "LVM handle reference stale"); \
@@ -175,8 +178,6 @@ static PyObject *_liblvm_get_last_error(void)
 
 static PyObject *_liblvm_library_get_version(void)
 {
-	LVM_VALID(NULL);
-
 	return Py_BuildValue("s", lvm_library_get_version());
 }
 
@@ -184,13 +185,9 @@ static const char _gc_doc[] = "Garbage collect the C library";
 
 static PyObject *_liblvm_lvm_gc(void)
 {
-	LVM_VALID(NULL);
-
-	lvm_quit(_libh);
-
-	if (!(_libh = lvm_init(NULL))) {
-		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		return NULL;
+	if (_libh) {
+		lvm_quit(_libh);
+		_libh = NULL;
 	}
 
 	Py_INCREF(Py_None);
@@ -2047,8 +2044,6 @@ PyMODINIT_FUNC initlvm(void)
 {
 	PyObject *m;
 
-	_libh = lvm_init(NULL);
-
 	if (PyType_Ready(&_LibLVMvgType) < 0)
 		MODINITERROR;
 	if (PyType_Ready(&_LibLVMlvType) < 0)


