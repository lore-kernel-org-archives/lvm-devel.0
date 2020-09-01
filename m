From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:35 +0000 (GMT)
Subject: master - tests: skip test when gcore cannot catch securetest
Message-ID: <20200901214135.02AAA386F823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ada5728c72e4620c54e4786f31ca5e45cf75d1b0
Commit:        ada5728c72e4620c54e4786f31ca5e45cf75d1b0
Parent:        bc13c7d2469d1c3fc1f8d76f9f93c9d594496bf0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 21:39:47 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

tests: skip test when gcore cannot catch securetest

---
 test/shell/dmsecuretest.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
index 144b1f4ae..6fbdb893c 100644
--- a/test/shell/dmsecuretest.sh
+++ b/test/shell/dmsecuretest.sh
@@ -45,7 +45,8 @@ sleep .5
 dmsetup status "$DMTEST"
 
 # generate core file for running&sleeping binary
-gcore "$PID" | tee out
+gcore "$PID" | tee out || skip
+
 # check we capture core while  dmsecuretest was already sleeping
 grep "nanosleep" out || grep kernel_vsyscall out
 kill "$PID" || true


