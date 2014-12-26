From: David Taylor <davidt-lvm2@yadt.co.uk>
Date: Fri, 26 Dec 2014 20:06:34 +0100
Subject: [PATCH 2/2] Expose readonly parameter of lvm_lv_snapshot() to python bindings.
In-Reply-To: <1419620794-29008-1-git-send-email-davidt-lvm2@yadt.co.uk>
References: <1419620794-29008-1-git-send-email-davidt-lvm2@yadt.co.uk>
Message-ID: <1419620794-29008-3-git-send-email-davidt-lvm2@yadt.co.uk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the new 'readonly' parameter of lvm_lv_snapshot() in liblvm2app
to the python liblvm module.
---
 python/liblvm.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 3828f27..19d6d6f 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1573,15 +1573,17 @@ static PyObject *_liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
 	const char *snap_name;
 	unsigned long long size = 0;
+	int readonly = 0;
+	struct lvm_property_value prop_value;
 	lv_t lv;
 	lv_create_params_t lvp = NULL;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s|K", &snap_name, &size))
+	if (!PyArg_ParseTuple(args, "s|Ki", &snap_name, &size, &readonly))
 		return NULL;
 
-	if (!(lvp = lvm_lv_params_create_snapshot(self->lv, snap_name, size))) {
+	if (!(lvp = lvm_lv_params_create_snapshot(self->lv, snap_name, size, readonly))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
-- 
2.1.4


