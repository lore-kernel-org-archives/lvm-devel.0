From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Apr 2015 16:03:38 +0000 (UTC)
Subject: master - python: Fix ws liblvm.c
Message-ID: <20150410160338.D29E860D29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0523c718446a13472d9bec8bce61e7ec020d0179
Commit:        0523c718446a13472d9bec8bce61e7ec020d0179
Parent:        f29df9acfe430093c07cff06aa302e5e70c07965
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Apr 10 11:01:46 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Apr 10 11:01:46 2015 -0500

python: Fix ws liblvm.c

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 74d65ea..1c9b5c4 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1445,9 +1445,9 @@ static PyObject *_liblvm_lvm_lv_add_tag(lvobject *self, PyObject *args)
 		return NULL;
 
 	if (lvm_lv_add_tag(self->lv, tag) == -1)
-        goto error;
+		goto error;
 
-    if (lvm_vg_write(self->parent_vgobj->vg) == -1)
+	if (lvm_vg_write(self->parent_vgobj->vg) == -1)
 		goto error;
 
 	Py_INCREF(Py_None);
@@ -1468,10 +1468,10 @@ static PyObject *_liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
 		return NULL;
 
 	if (lvm_lv_remove_tag(self->lv, tag) == -1)
-        goto error;
+		goto error;
 
-    if (lvm_vg_write(self->parent_vgobj->vg) == -1)
-        goto error;
+	if (lvm_vg_write(self->parent_vgobj->vg) == -1)
+		goto error;
 
 	Py_INCREF(Py_None);
 	return Py_None;


