From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 10:36:34 -0400
Subject: master - tests: don't look for liblvm
Message-ID: <201806081436.w58EaY3B025833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dbc3e62cc079c00bb48987848a6315fb0a7372f8
Commit:        dbc3e62cc079c00bb48987848a6315fb0a7372f8
Parent:        73b7e6fde720601b6c2d8e36d818c89580f097ff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 09:36:03 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 09:36:03 2018 -0500

tests: don't look for liblvm

---
 test/lib/utils.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 36fbf06..2cd00dd 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -276,7 +276,7 @@ if test -z "${installed_testsuite+varset}"; then
     *)
 	PATH="$abs_top_builddir/test/lib:$abs_top_builddir/test/api:$PATH"
 	LD_LIBRARY_PATH=$(find -L "$abs_top_builddir/libdm/" "$abs_top_builddir/tools/"\
-		"$abs_top_builddir/daemons/" "$abs_top_builddir/liblvm/"\
+		"$abs_top_builddir/daemons/" \
 		-name "*.so" -printf "%h:")"$LD_LIBRARY_PATH"
 	export PATH LD_LIBRARY_PATH ;;
     esac


