From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Feb 2021 11:10:38 +0000 (GMT)
Subject: stable-2.02 - tests: update setting LVM_BINARY for testing
Message-ID: <20210224111038.27FF6386103F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2b693fbe6139b0b991ea84a3011a74586b3b702
Commit:        e2b693fbe6139b0b991ea84a3011a74586b3b702
Parent:        1f220e8d430f3ab94e3e85656a3f692c6dc4051f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 16:27:44 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 16:29:48 2021 +0100

tests: update setting LVM_BINARY for testing

When testing is running on uninstealled system - prefer our own binary
in tests.
---
 test/lib/aux.sh   | 2 +-
 test/lib/utils.sh | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4b303474a..9449b86cf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -177,7 +177,7 @@ prepare_clvmd() {
 	echo "<======== Starting CLVMD ========>"
 	echo -n "## preparing clvmd..."
 	# lvs is executed from clvmd - use our version
-	LVM_LOG_FILE_EPOCH=CLVMD LVM_LOG_FILE_MAX_LINES=1000000 LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
+	LVM_LOG_FILE_EPOCH=CLVMD LVM_LOG_FILE_MAX_LINES=1000000 $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
 	for i in {200..0} ; do
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index f01f5bdb0..f12a87990 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -280,10 +280,11 @@ if test -z "${installed_testsuite+varset}"; then
     *"$abs_top_builddir/test/lib"*) ;;
     *)
 	PATH="$abs_top_builddir/test/lib:$abs_top_builddir/test/api:$PATH"
+	LVM_BINARY=$(which lvm)
 	LD_LIBRARY_PATH=$(find -L "$abs_top_builddir/libdm/" "$abs_top_builddir/tools/"\
 		"$abs_top_builddir/daemons/" "$abs_top_builddir/liblvm/"\
 		-name "*.so" -printf "%h:")"$LD_LIBRARY_PATH"
-	export PATH LD_LIBRARY_PATH ;;
+	export PATH LD_LIBRARY_PATH LVM_BINARY ;;
     esac
 fi
 


