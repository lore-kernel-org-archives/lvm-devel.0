From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 26 Oct 2012 15:40:09 -0500
Subject: [PATCH 1/2] test: set LD_LIBRARY_PATH to all dirs with *.so
Message-ID: <1351284010-8247-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of manually editing entries, add all the
directories which contain shared objects.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/lib/utils.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 70d9f66..ab5abc1 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -204,11 +204,11 @@ test -n "${abs_top_builddir+varset}" || . lib/paths || die "you must run make fi
 case "$PATH" in
 *"$abs_top_builddir/test/lib"*) ;;
 *)
-        PATH="$abs_top_builddir/test/lib":$PATH
-        for d in daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot \
-                daemons/dmeventd/plugins/lvm2 daemons/dmeventd liblvm tools libdm; do
-                LD_LIBRARY_PATH="$abs_top_builddir/$d":$LD_LIBRARY_PATH
-        done
+	PATH="$abs_top_builddir/test/lib":"$abs_top_builddir/test/api":$PATH
+	for i in `find $abs_top_builddir -name \*.so`; do
+		p=`dirname $i`
+		LD_LIBRARY_PATH="$p":$LD_LIBRARY_PATH
+	done
         export PATH LD_LIBRARY_PATH ;;
 esac
 
-- 
1.7.1


