From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:33 +0000 (UTC)
Subject: master - python-lvm: Added lv method getOrigin
Message-ID: <20130702192633.EF80C60FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f576b32203e4c1001764d26225fc6dffa97e4da0
Commit:        f576b32203e4c1001764d26225fc6dffa97e4da0
Parent:        a7f3dbf904f369338657785e845ebc8a6f479983
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Apr 11 16:49:08 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Added lv method getOrigin

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 381af62..305fd50 100644
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


