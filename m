From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 23:42:19 +0000 (GMT)
Subject: main - tests: use shell comment
Message-ID: <20210326234219.1DD0B385800F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a55f4a8fe24a89c9a7e42e2fcd11c974eae0e127
Commit:        a55f4a8fe24a89c9a7e42e2fcd11c974eae0e127
Parent:        93336685f6cf8a178cb83aa1ee113a2a33ca7f5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 22:12:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 22:12:42 2021 +0100

tests: use shell comment

---
 test/shell/hints.sh | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index b2a53c678..a11aeec23 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -12,9 +12,11 @@
 
 SKIP_WITH_LVMPOLLD=1
 
-/* hints are currently disabled with lvmlockd */
+# hints are currently disabled with lvmlockd
 SKIP_WITH_LVMLOCKD=1
 
+. lib/inittest
+
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 HINTS="$RUNDIR/lvm/hints"
@@ -22,8 +24,6 @@ NOHINTS="$RUNDIR/lvm/nohints"
 NEWHINTS="$RUNDIR/lvm/newhints"
 PREV="$RUNDIR/lvm/prev-hints"
 
-. lib/inittest
-
 # TODO:
 # Test commands that ignore hints
 # Test flock
@@ -55,7 +55,7 @@ not grep scan: tmptest
 # test that 'pvs' submits only three reads, one for each PV in hints
 # for initial scan, and one more in vg_read rescan check
 
-if [ -e "/usr/bin/strace" ]; then
+if which strace; then
 strace -e io_submit pvs 2>&1|tee tmptest
 test "$(grep io_submit tmptest | wc -l)" -eq 3
 
@@ -413,4 +413,3 @@ grep $vg4 $HINTS
 vgremove -y $vg4
 vgremove -y $vg2
 vgremove -y $vg1
-


