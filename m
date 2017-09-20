From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Sep 2017 07:08:48 -0400
Subject: master - liblvm: Deprecate library and bindings
Message-ID: <201709201108.v8KB8mGU017003@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4cbacf6bac47227ec3460da1619ab29557f2c89b
Commit:        4cbacf6bac47227ec3460da1619ab29557f2c89b
Parent:        5407327bc6fff77dabb6dd55150832373ba163a7
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Sep 19 15:17:01 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 20 13:07:06 2017 +0200

liblvm: Deprecate library and bindings

It is recommended to use D-Bus API instead of liblvm2app or python
bindings.
---
 liblvm/lvm2app.h |    2 ++
 python/liblvm.c  |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index be53b2d..f64262d 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -18,6 +18,8 @@
 
 #include <stdint.h>
 
+#warning "liblvm2app is deprecated, use D-Bus API instead."
+
 #ifdef __cplusplus
 extern "C" {
 #endif
diff --git a/python/liblvm.c b/python/liblvm.c
index 1b3534e..6d67b8b 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -2085,6 +2085,8 @@ PyMODINIT_FUNC initlvm(void)
 		PyModule_AddObject(m, "LibLVMError", _LibLVMError);
 	}
 
+	PyErr_Warn(PyExc_DeprecationWarning, "Python API is deprecated, use D-Bus API instead.");
+
 	Py_AtExit(_liblvm_cleanup);
 #ifdef IS_PY3K
 	return m;


