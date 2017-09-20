From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Sep 2017 07:08:52 -0400
Subject: master - configure: Update configure
Message-ID: <201709201108.v8KB8qAj017016@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c46f9cf0cf712e96dd2078b9121df1078b11e2a
Commit:        0c46f9cf0cf712e96dd2078b9121df1078b11e2a
Parent:        8493df8eddc5a05a2af9a9c4d8e11192f07ec79a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 20 10:13:39 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 20 13:07:06 2017 +0200

configure: Update configure

---
 configure |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 2afbe6e..78c738d 100755
--- a/configure
+++ b/configure
@@ -12791,6 +12791,10 @@ $as_echo "$APPLIB" >&6; }
 test "$APPLIB" = yes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
+if test "$APPLIB"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Python bindings are deprecated. Use D-Bus API" >&5
+$as_echo "$as_me: WARNING: Python bindings are deprecated. Use D-Bus API" >&2;}
+fi
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to compile liblvm2cmd.so" >&5
@@ -13868,6 +13872,8 @@ $as_echo "no" >&6; }
 fi
 
 if test "$PYTHON_BINDINGS" = yes -o "$PYTHON2_BINDINGS" = yes -o "$PYTHON3_BINDINGS" = yes; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Python bindings are deprecated. Use D-Bus API" >&5
+$as_echo "$as_me: WARNING: Python bindings are deprecated. Use D-Bus API" >&2;}
 	test "$APPLIB" != yes && as_fn_error $? "Python_bindings require --enable-applib" "$LINENO" 5
 fi
 


