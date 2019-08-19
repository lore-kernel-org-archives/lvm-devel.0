From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 19 Aug 2019 09:33:57 -0400
Subject: master - configure: Fix setting of CLDFLAGS default
Message-ID: <201908191333.x7JDXvGg010901@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a3e707402032788e09282e0f54fdf82c8a0f8fc
Commit:        4a3e707402032788e09282e0f54fdf82c8a0f8fc
Parent:        9b63f590168b14d0e996f62519edb27f24ab83e2
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Aug 19 14:54:43 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Aug 19 15:28:01 2019 +0200

configure: Fix setting of CLDFLAGS default

---
 configure    |    6 +++---
 configure.ac |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index ff3a59b..4c84765 100755
--- a/configure
+++ b/configure
@@ -3077,7 +3077,7 @@ if test -z "$CFLAGS"; then :
 fi
 case "$host_os" in
 	linux*)
-		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"} -Wl,--version-script,.export.sym"
+		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -3098,7 +3098,7 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
+		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
@@ -3111,7 +3111,7 @@ case "$host_os" in
 		BLKDEACTIVATE=no
 		;;
 	*)
-		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
+		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
 		;;
 esac
 
diff --git a/configure.ac b/configure.ac
index 5da6946..830edb8 100644
--- a/configure.ac
+++ b/configure.ac
@@ -30,7 +30,7 @@ AC_CANONICAL_TARGET([])
 AS_IF([test -z "$CFLAGS"], [COPTIMISE_FLAG="-O2"])
 case "$host_os" in
 	linux*)
-		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"} -Wl,--version-script,.export.sym"
+		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -51,7 +51,7 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
+		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
@@ -64,7 +64,7 @@ case "$host_os" in
 		BLKDEACTIVATE=no
 		;;
 	*)
-		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
+		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
 		;;
 esac
 


