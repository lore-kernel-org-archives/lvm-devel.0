From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 10 Apr 2013 13:41:24 -0500
Subject: [PATCH 2/2] python-lvm: Add method to retrieve lv attr.
In-Reply-To: <1365619284-4238-1-git-send-email-tasleson@redhat.com>
References: <1365619284-4238-1-git-send-email-tasleson@redhat.com>
Message-ID: <1365619284-4238-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/python/liblvm.c b/python/liblvm.c
index c76a3d0..96e94d4 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1193,6 +1193,13 @@ liblvm_pv_dealloc(pvobject *self)
 		}							\
 	} while (0)
 
+static PyObject *
+liblvm_lvm_lv_get_attr(lvobject *self)
+{
+	LV_VALID(self);
+
+	return Py_BuildValue("s", lvm_lv_get_attr(self->lv));
+}
 
 static PyObject *
 liblvm_lvm_lv_get_name(lvobject *self)
@@ -1749,6 +1756,7 @@ static PyMethodDef liblvm_vg_methods[] = {
 
 static PyMethodDef liblvm_lv_methods[] = {
 	/* lv methods */
+	{ "getAttr",		(PyCFunction)liblvm_lvm_lv_get_attr, METH_NOARGS },
 	{ "getName",		(PyCFunction)liblvm_lvm_lv_get_name, METH_NOARGS },
 	{ "getUuid",		(PyCFunction)liblvm_lvm_lv_get_uuid, METH_NOARGS },
 	{ "activate",		(PyCFunction)liblvm_lvm_lv_activate, METH_NOARGS },
-- 
1.8.1.4


