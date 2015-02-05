From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:08 +0000 (UTC)
Subject: master - test: Make it possible to run tests from an installed location.
Message-ID: <20150205134108.A49AF60A54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4215f956f4576ce38b19a9a9ca216e9d096fe5a
Commit:        b4215f956f4576ce38b19a9a9ca216e9d096fe5a
Parent:        569895394895ea4354a3ab8de919f99acf5a5e87
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:59:17 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Make it possible to run tests from an installed location.

---
 test/lib/utils.sh |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index b4cfdeb..70f8ca5 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -207,18 +207,21 @@ prepare_test_vars() {
 	done
 }
 
-# check if $abs_top_builddir was already set via 'lib/paths'
-test -n "${abs_top_builddir+varset}" || . lib/paths || die "you must run make first"
-
-case "$PATH" in
-*"$abs_top_builddir/test/lib"*) ;;
-*)
-	PATH="$abs_top_builddir/test/lib":"$abs_top_builddir/test/api":$PATH
-	for i in `find $abs_top_builddir -name \*.so`; do
-		p=`dirname $i`
-		LD_LIBRARY_PATH="$p":$LD_LIBRARY_PATH
-	done
-        export PATH LD_LIBRARY_PATH ;;
-esac
+if test -z "${abs_top_builddir+varset}" && test -z "${installed_testsuite+varset}"; then
+    . lib/paths || die "something went wrong -- lib/paths is missing?"
+fi
+
+if test -z "${installed_testsuite+varset}"; then
+    case "$PATH" in
+    *"$abs_top_builddir/test/lib"*) ;;
+    *)
+	    PATH="$abs_top_builddir/test/lib":"$abs_top_builddir/test/api":$PATH
+	    for i in `find $abs_top_builddir -name \*.so`; do
+		    p=`dirname $i`
+		    LD_LIBRARY_PATH="$p":$LD_LIBRARY_PATH
+	    done
+            export PATH LD_LIBRARY_PATH ;;
+    esac
+fi
 
 test -z "$PREFIX" || prepare_test_vars


