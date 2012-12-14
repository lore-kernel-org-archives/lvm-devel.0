From: Andy Grover <grover@fedoraproject.org>
Date: Fri, 14 Dec 2012 22:11:08 +0000 (UTC)
Subject: master - python-lvm: Make second lv.snapshot() argument optional
Message-ID: <20121214221108.E6D52137F@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0958905b1bc0a59d34a4092377bae7c59f424181
Commit:        0958905b1bc0a59d34a4092377bae7c59f424181
Parent:        0e3093979e901384aecb22e08d83b5acb2ef12c1
Author:        Andy Grover <agrover@redhat.com>
AuthorDate:    Fri Dec 14 14:10:41 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Fri Dec 14 14:10:41 2012 -0800

python-lvm: Make second lv.snapshot() argument optional

If no size is given, size defaults to 0, which in lvm_lv_snapshot will
allocate extents equal to the original LV be allocated for the new
snapshot.

Signed-off-by: Andy Grover <agrover@redhat.com>
---
 python/liblvm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 906825e..4db507c 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1317,12 +1317,12 @@ static PyObject *
 liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
 	const char *vgname;
-	uint64_t size;
+	uint64_t size = 0;
 	lvobject *lvobj;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
+	if (!PyArg_ParseTuple(args, "s|l", &vgname, &size)) {
 		return NULL;
 	}
 


