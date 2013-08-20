From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 20 Aug 2013 15:20:14 +0900
Subject: [PATCH] configure: Set PTHREAD_LIBS when lvmetad is enabled
Message-ID: <52130A9E.9040001@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I hit a build error like this when I enabled lvmetad without dmeventd/clvmd:

cc  -fPIC  -O2  -O2 -L../../libdm -L../../lib -L../../libdaemon/client -L../../libdaemon/server -o lvmetad lvmetad-core.o \
-ldl -ldaemonserver -llvm-internal -ldaemonclient -ludev   -ldl -ldevmapper   -rdynamic
/usr/bin/ld: lvmetad-core.o: undefined reference to symbol 'pthread_mutexattr_settype@@GLIBC_2.2.5'
/usr/bin/ld: note: 'pthread_mutexattr_settype@@GLIBC_2.2.5' is defined in DSO /lib64/libpthread.so.0 so try adding it to the linker command line
/lib64/libpthread.so.0: could not read symbols: Invalid operation
collect2: error: ld returned 1 exit status
make[2]: *** [lvmetad] Error 1
make[2]: Leaving directory `/work/lvm2/daemons/lvmetad'
make[1]: *** [lvmetad] Error 2
make[1]: Leaving directory `/work/lvm2/daemons'
make: *** [daemons] Error 2

Attached is a trivial patch to fix this.

---
Jun'ichi Nomura, NEC Corporation

diff --git a/configure b/configure
index 20a706a..070f6c1 100755
--- a/configure
+++ b/configure
@@ -9668,7 +9668,7 @@ if [ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
 fi
 
 ################################################################################
-if [ "$DMEVENTD" = yes -o "$CLVMD" != none ] ; then
+if [ "$DMEVENTD" = yes -o "$CLVMD" != none -o "$LVMETAD" = yes ] ; then
 	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
 $as_echo_n "checking for pthread_mutex_lock in -lpthread... " >&6; }
 if test "${ac_cv_lib_pthread_pthread_mutex_lock+set}" = set; then :
diff --git a/configure.in b/configure.in
index 611ab37..d32d8cd 100644
--- a/configure.in
+++ b/configure.in
@@ -1181,7 +1181,7 @@ Features cannot be 'shared' when building statically
 fi
 
 ################################################################################
-if [[ "$DMEVENTD" = yes -o "$CLVMD" != none ]] ; then
+if [[ "$DMEVENTD" = yes -o "$CLVMD" != none -o "$LVMETAD" = yes ]] ; then
 	AC_CHECK_LIB([pthread], [pthread_mutex_lock],
 		[PTHREAD_LIBS="-lpthread"], hard_bailout)
 fi


