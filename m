From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:29 +0000 (UTC)
Subject: master - python-lvm: Add method to retrieve lv attr.
Message-ID: <20130702192629.CE8C060FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e0260c2e34f1b7150fb2fac3e780c3e75cd411e
Commit:        9e0260c2e34f1b7150fb2fac3e780c3e75cd411e
Parent:        952605a8ea3a7c9eabeb89bb3d644b8b04b4239b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 10 14:38:18 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Add method to retrieve lv attr.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 4d35c94..381af62 100644
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


