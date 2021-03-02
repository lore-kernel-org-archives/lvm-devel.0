From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:09 +0000 (GMT)
Subject: main - tests: update setting LVM_BINARY for testing
Message-ID: <20210302215809.BAA593834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7528a3363071b201c1f71a15e40cb9855ae169cf
Commit:        7528a3363071b201c1f71a15e40cb9855ae169cf
Parent:        3bab1a10264bf0d546cb5f0948ca382c9c882910
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 16:27:44 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:24:51 2021 +0100

tests: update setting LVM_BINARY for testing

When testing is running on uninstealled system - prefer our own binary
in tests.
---
 test/lib/aux.sh   | 2 +-
 test/lib/utils.sh | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c53d07b9e..1500e1f6a 100644
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
index 175d1564a..9da9a966e 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -296,10 +296,11 @@ if test -z "${installed_testsuite+varset}"; then
     *"$abs_top_builddir/test/lib"*) ;;
     *)
 	PATH="$abs_top_builddir/test/lib:$abs_top_builddir/test/api:$PATH"
+	LVM_BINARY=$(which lvm)
 	LD_LIBRARY_PATH=$(find -L "$abs_top_builddir/libdm/" "$abs_top_builddir/tools/"\
 		"$abs_top_builddir/daemons/" \
 		-name "*.so" -printf "%h:")"$LD_LIBRARY_PATH"
-	export PATH LD_LIBRARY_PATH ;;
+	export PATH LD_LIBRARY_PATH LVM_BINARY ;;
     esac
 fi
 


