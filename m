From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:37 +0000 (UTC)
Subject: master - python-lvm: Add addl. PV create arguments
Message-ID: <20131119205637.677A460EA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=531d85a0ee3854e49f9b81658dd6d7c60bb4de86
Commit:        531d85a0ee3854e49f9b81658dd6d7c60bb4de86
Parent:        04304ba7356c90568dcf32f0772a2023f4684656
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 10 18:05:28 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:36 2013 -0600

python-lvm: Add addl. PV create arguments

Added overloaded PV create arguments with defaults for PV
creation.

Addresses bug: https://bugzilla.redhat.com/show_bug.cgi?id=880395

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   51 +++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 36b64e4..033de82 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -23,6 +23,7 @@
 
 #include <Python.h>
 #include "lvm2app.h"
+#include "defaults.h"
 
 static lvm_t _libh;
 
@@ -317,24 +318,62 @@ static PyObject *_liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
 	return Py_None;
 }
 
+static int _set_pv_numeric_prop(pv_create_params_t pv_params, const char *name,
+								unsigned long long value)
+{
+	struct lvm_property_value prop_value;
+	prop_value.is_integer = 1;
+	prop_value.value.integer = value;
+
+	return lvm_pv_params_set_property(pv_params, name, &prop_value);
+}
+
+#define SET_PV_PROP(params, name, value) \
+	do { \
+		if (_set_pv_numeric_prop(params, name, value) == -1) \
+			goto error; \
+	} while(0)\
+
 static PyObject *_liblvm_lvm_pv_create(PyObject *self, PyObject *arg)
 {
 	const char *pv_name;
-	unsigned long long size;
+	unsigned long long size = 0;
+	unsigned long long pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	unsigned long long pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	unsigned long long data_alignment = 0;
+	unsigned long long data_alignment_offset = 0;
+	unsigned long long zero = 1;
+	pv_create_params_t pv_params = NULL;
 
 	LVM_VALID(NULL);
 
-	if (!PyArg_ParseTuple(arg, "sK", &pv_name, &size))
+	if (!PyArg_ParseTuple(arg, "s|KKKKKK", &pv_name, &size, &pvmetadatacopies,
+							&pvmetadatasize, &data_alignment,
+							&data_alignment_offset, &zero))
 		return NULL;
 
-	if (lvm_pv_create(_libh, pv_name, size) == -1) {
-		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		return NULL;
+	pv_params = lvm_pv_params_create(_libh, pv_name);
+	if (!pv_params) {
+		goto error;
 	}
 
-	Py_INCREF(Py_None);
+	SET_PV_PROP(pv_params, "size", size);
+	SET_PV_PROP(pv_params, "pvmetadatacopies", pvmetadatacopies);
+	SET_PV_PROP(pv_params, "pvmetadatasize", pvmetadatasize);
+	SET_PV_PROP(pv_params, "data_alignment", data_alignment);
+	SET_PV_PROP(pv_params, "data_alignment_offset", data_alignment_offset);
+	SET_PV_PROP(pv_params, "zero", zero);
+
+	if (lvm_pv_create_adv(pv_params)) {
+		goto error;
+	}
 
+	Py_INCREF(Py_None);
 	return Py_None;
+
+error:
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+	return NULL;
 }
 
 static PyObject *_liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)


