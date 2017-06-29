From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:06 -0400
Subject: master - tests: lvm-wrapper.sh legacy syntax
Message-ID: <201706292029.v5TKT6iX026908@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b442861f50eee6e571143fc8b62131be13e7aa91
Commit:        b442861f50eee6e571143fc8b62131be13e7aa91
Parent:        b1f80512c8965087fd77284078385afc689e845f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:02:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: lvm-wrapper.sh legacy syntax

---
 test/lib/lvm-wrapper.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 41fbec9..129cafe 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -48,6 +48,6 @@ esac
 if test -n "$abs_top_builddir"; then
     exec $RUN_DBG "$abs_top_builddir/tools/lvm" $CMD "$@"
 else # we are testing the lvm on $PATH
-    PATH=`echo $PATH | sed -e s,[^:]*lvm2-testsuite[^:]*:,,g`
+    PATH=$(echo "$PATH" | sed -e s,[^:]*lvm2-testsuite[^:]*:,,g)
     exec $RUN_DBG lvm $CMD "$@"
 fi


