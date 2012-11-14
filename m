From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 14 Nov 2012 19:25:55 +0000 (UTC)
Subject: master - test: set LD_LIBRARY_PATH to all dirs with *.so
Message-ID: <20121114192555.D6255A0C24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fefb2f03c3fe49e855f21f7d4952b6a2318113cc
Commit:        fefb2f03c3fe49e855f21f7d4952b6a2318113cc
Parent:        fc2644ae71a87ea81979f66022b98ec49c692a66
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 26 15:30:21 2012 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 14 13:05:55 2012 -0600

test: set LD_LIBRARY_PATH to all dirs with *.so

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
 


