From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 31 Oct 2018 10:36:46 -0400
Subject: master - build: Fix CLDFLAGS default
Message-ID: <201810311436.w9VEaks6032722@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e40e734e6da2ee4b20286a132eafe679d5695d1
Commit:        1e40e734e6da2ee4b20286a132eafe679d5695d1
Parent:        aecf542126640faa17c240afbb1ea61f11355c39
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 22 12:56:34 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Oct 30 10:15:44 2018 +0100

build: Fix CLDFLAGS default

---
 configure    |    7 +++++--
 configure.ac |    7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index 286733c..d8f7384 100755
--- a/configure
+++ b/configure
@@ -3067,7 +3067,7 @@ if test -z "$CFLAGS"; then :
 fi
 case "$host_os" in
 	linux*)
-		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
+		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"} -Wl,--version-script,.export.sym"
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -3087,7 +3087,7 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		CLDFLAGS="$CLDFLAGS"
+		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
@@ -3099,6 +3099,9 @@ case "$host_os" in
 		FSADM=no
 		BLKDEACTIVATE=no
 		;;
+	*)
+		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
+		;;
 esac
 
 ################################################################################
diff --git a/configure.ac b/configure.ac
index c5d3207..70fd674 100644
--- a/configure.ac
+++ b/configure.ac
@@ -30,7 +30,7 @@ AC_CANONICAL_TARGET([])
 AS_IF([test -z "$CFLAGS"], [COPTIMISE_FLAG="-O2"])
 case "$host_os" in
 	linux*)
-		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
+		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"} -Wl,--version-script,.export.sym"
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -50,7 +50,7 @@ case "$host_os" in
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
-		CLDFLAGS="$CLDFLAGS"
+		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
@@ -62,6 +62,9 @@ case "$host_os" in
 		FSADM=no
 		BLKDEACTIVATE=no
 		;;
+	*)
+		CLDFLAGS="${CLDFLAGS:"$LDFLAGS"}"
+		;;
 esac
 
 ################################################################################


