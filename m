From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 11 Apr 2013 15:58:51 -0500
Subject: [PATCH 2/2] python-lvm: Added lv method getOrigin
In-Reply-To: <1365713931-12666-1-git-send-email-tasleson@redhat.com>
References: <1365713931-12666-1-git-send-email-tasleson@redhat.com>
Message-ID: <1365713931-12666-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/python/liblvm.c b/python/liblvm.c
index 96e94d4..09892ca 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1202,6 +1202,14 @@ liblvm_lvm_lv_get_attr(lvobject *self)
 }
 
 static PyObject *
+liblvm_lvm_lv_get_origin(lvobject *self)
+{
+	LV_VALID(self);
+
+	return Py_BuildValue("s", lvm_lv_get_origin(self->lv));
+}
+
+static PyObject *
 liblvm_lvm_lv_get_name(lvobject *self)
 {
 	LV_VALID(self);
@@ -1758,6 +1766,7 @@ static PyMethodDef liblvm_lv_methods[] = {
 	/* lv methods */
 	{ "getAttr",		(PyCFunction)liblvm_lvm_lv_get_attr, METH_NOARGS },
 	{ "getName",		(PyCFunction)liblvm_lvm_lv_get_name, METH_NOARGS },
+	{ "getOrigin",		(PyCFunction)liblvm_lvm_lv_get_origin, METH_NOARGS },
 	{ "getUuid",		(PyCFunction)liblvm_lvm_lv_get_uuid, METH_NOARGS },
 	{ "activate",		(PyCFunction)liblvm_lvm_lv_activate, METH_NOARGS },
 	{ "deactivate",		(PyCFunction)liblvm_lvm_lv_deactivate, METH_NOARGS },
-- 
1.8.1.4


