From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:23:33 +0000 (UTC)
Subject: dev-mornfall-activate - test: Re-instate exec in lvm-wrapper, catching crashes inside not.
Message-ID: <20130604192333.A02E860EDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91c9771fc3c97b0ff1169cf81f29918d3e3a501d
Commit:        91c9771fc3c97b0ff1169cf81f29918d3e3a501d
Parent:        cbcbb677313aa8a4116bcfd13ceccef05fb1f9a9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Apr 11 16:22:35 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Apr 11 16:22:35 2013 +0200

test: Re-instate exec in lvm-wrapper, catching crashes inside not.

---
 test/lib/lvm-wrapper.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index d3a2a36..c69e29a 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -28,5 +28,5 @@ if test -n "$LVM_VALGRIND"; then
 	esac
 fi
 
-$RUN_VALGRIND "$abs_top_builddir/tools/lvm" $CMD "$@" && \
-	rm -f debug.log # Remove log for successful command
+# the exec is important, because otherwise fatal signals inside "not" go unnoticed
+exec $RUN_VALGRIND "$abs_top_builddir/tools/lvm" $CMD "$@"


