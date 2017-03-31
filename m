From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 31 Mar 2017 11:12:59 -0400
Subject: master - tests: fix LD_LIBRARY_PATH
Message-ID: <201703311512.v2VFCxX3008488@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb1f38a6f677c0127807e6ee403af21c6d6e25da
Commit:        fb1f38a6f677c0127807e6ee403af21c6d6e25da
Parent:        970df59f914733b9ade15d9cb48e758b08140d42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 31 15:27:58 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 31 17:12:00 2017 +0200

tests: fix LD_LIBRARY_PATH

Use only selected paths for finding .so in builddir.
So if builddir constains some embeded subdirs with some more
occurences of project (i.e.  'make rpm' build subdir)
those library paths will not get into list.
---
 test/lib/utils.sh |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index ce90cdc..60979cc 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -258,12 +258,11 @@ if test -z "${installed_testsuite+varset}"; then
     case "$PATH" in
     *"$abs_top_builddir/test/lib"*) ;;
     *)
-	    PATH="$abs_top_builddir/test/lib":"$abs_top_builddir/test/api":$PATH
-	    for i in `find $abs_top_builddir -name \*.so`; do
-		    p=`dirname $i`
-		    LD_LIBRARY_PATH="$p":$LD_LIBRARY_PATH
-	    done
-            export PATH LD_LIBRARY_PATH ;;
+	PATH="$abs_top_builddir/test/lib":"$abs_top_builddir/test/api":$PATH
+	LD_LIBRARY_PATH=$(find -L "$abs_top_builddir/libdm/" "$abs_top_builddir/tools/"\
+		"$abs_top_builddir/daemons/" "$abs_top_builddir/liblvm/"\
+		-name "*.so" -printf "%h:")"$LD_LIBRARY_PATH"
+	export PATH LD_LIBRARY_PATH ;;
     esac
 fi
 


