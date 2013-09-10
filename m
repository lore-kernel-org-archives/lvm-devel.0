From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 10 Sep 2013 18:13:01 -0500
Subject: [PATCH 3/3] python-lvm: Add addl. PV create arguments
In-Reply-To: <1378854781-16339-1-git-send-email-tasleson@redhat.com>
References: <1378854781-16339-1-git-send-email-tasleson@redhat.com>
Message-ID: <1378854781-16339-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added overloaded PV create arguments with defaults for PV
creation.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 51 +++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 45 insertions(+), 6 deletions(-)

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
-- 
1.8.2.1


