From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 18 Jul 2013 21:04:28 +0000 (UTC)
Subject: master - python-lvm: Add call to close/re-open C lib.
Message-ID: <20130718210428.091E3606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a005b40a4ce9cc1f54a564f8f74917935cb35c4
Commit:        1a005b40a4ce9cc1f54a564f8f74917935cb35c4
Parent:        357df34133fae754eb25cf3c3a784b1905fc9291
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Jul 18 16:53:43 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jul 18 16:03:29 2013 -0500

python-lvm: Add call to close/re-open C lib.

As the library handle has a dm pool associated with
it for long running processes it is required to close and
re-open the library to free the dm pool.  Call added so
python clients can reclaim memory, lvm.gc().

Note: Any python objects on the heap become invalid at the
time this call is made.  If referenced, a seg. fault could
occur.  No simple way to make this safe with the current
memory management in the C library.  Use with caution!

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index cdeb4bf..8fa26ea 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -128,6 +128,24 @@ liblvm_library_get_version(void)
 	return Py_BuildValue("s", lvm_library_get_version());
 }
 
+const static char gc_doc[] = "Garbage collect the C library";
+
+static PyObject *
+liblvm_lvm_gc(void)
+{
+	LVM_VALID();
+
+	lvm_quit(libh);
+	libh = lvm_init(NULL);
+
+	if (!libh) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+				return NULL;
+	}
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
 static PyObject *
 liblvm_lvm_list_vg_names(void)
 {
@@ -1844,6 +1862,7 @@ liblvm_lvm_pvseg_get_property(pvsegobject *self, PyObject *args)
 static PyMethodDef Liblvm_methods[] = {
 	/* LVM methods */
 	{ "getVersion",		(PyCFunction)liblvm_library_get_version, METH_NOARGS },
+	{ "gc",				(PyCFunction)liblvm_lvm_gc, METH_NOARGS, gc_doc },
 	{ "vgOpen",		(PyCFunction)liblvm_lvm_vg_open, METH_VARARGS },
 	{ "vgCreate",		(PyCFunction)liblvm_lvm_vg_create, METH_VARARGS },
 	{ "configFindBool",	(PyCFunction)liblvm_lvm_config_find_bool, METH_VARARGS },
@@ -2024,8 +2043,10 @@ static PyTypeObject LibLVMpvsegType = {
 static void
 liblvm_cleanup(void)
 {
-	lvm_quit(libh);
-	libh = NULL;
+	if (libh) {
+		lvm_quit(libh);
+		libh = NULL;
+	}
 }
 
 PyMODINIT_FUNC


