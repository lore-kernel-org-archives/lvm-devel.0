From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Jul 2019 17:52:39 -0400
Subject: master - tests: lvm-on-md use variable run dir
Message-ID: <201907122152.x6CLqdJa017098@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa58f9bd9b28e8b734a6d723234f9ed1de28265b
Commit:        aa58f9bd9b28e8b734a6d723234f9ed1de28265b
Parent:        bbca70a0b7de682ce3f4547f313f55a9a44ed89d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 12 16:51:49 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 12 16:51:49 2019 -0500

tests: lvm-on-md use variable run dir

for hints file
---
 test/shell/lvm-on-md.sh |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index c848083..2877ea2 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -16,6 +16,7 @@ RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
 VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+HINTS="$RUNDIR/lvm/hints"
 
 _clear_online_files() {
         # wait till udev is finished
@@ -330,10 +331,10 @@ pvs > out
 not grep "$dev1" out
 not grep "$dev2" out
 
-grep "$mddev" /run/lvm/hints
-grep "$dev3" /run/lvm/hints
-not grep "$dev1" /run/lvm/hints
-not grep "$dev2" /run/lvm/hints
+grep "$mddev" $HINTS
+grep "$dev3" $HINTS
+not grep "$dev1" $HINTS
+not grep "$dev2" $HINTS
 
 sleep 1
 
@@ -363,7 +364,7 @@ not grep "$mddev" out2
 not grep "$dev1" out2
 not grep "$dev2" out2
 grep "$dev3" out2
-cat /run/lvm/hints
+cat $HINTS
 
 pvs 2>&1|tee out1
 grep -v WARNING out1 > out2
@@ -372,7 +373,7 @@ not grep "$mddev" out2
 not grep "$dev1" out2
 not grep "$dev2" out2
 grep "$dev3" out2
-cat /run/lvm/hints
+cat $HINTS
 
 # The md components should still be detected and excluded.
 not pvs "$dev1"


