From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:32:01 -0400
Subject: master - tests: avoid checking command result in cluster
Message-ID: <201911011532.xA1FW1no016965@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1c5b3ae740481290de14d1ea178e571e689ff0e
Commit:        d1c5b3ae740481290de14d1ea178e571e689ff0e
Parent:        569e328cc014d467fcdeed6fe34eaaf7070d7e13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 15:46:16 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:27:21 2019 +0100

tests: avoid checking command result in cluster

When running cluster test with clvmd, the actual 'monitoring'
happens in cluster - so the 'already monitored' message
is also logged within clvmd code and the command cannot
see such effect.

clvmd was incapable to report this information back to command
so it cannot be displayed this way.

Add 'lvs -o+seg_monitor' validation which also works in clustered mode.
---
 test/shell/dmeventd-restart.sh |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 5267290..151f1d5 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -31,10 +31,13 @@ dmeventd -R -f &
 echo $! >LOCAL_DMEVENTD
 sleep 2 # wait a bit, so we talk to the new dmeventd later
 
+check lv_field $vg/3way seg_monitor "monitored"
+check lv_field $vg/4way seg_monitor "monitored"
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
-grep 'already monitored' lvchange.out
+# only non-cluster tests can check command result
+test -e LOCAL_CLVMD || grep 'already monitored' lvchange.out
 lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
-grep 'already monitored' lvchange.out
+test -e LOCAL_CLVMD || grep 'already monitored' lvchange.out
 
 # now try what happens if no dmeventd is running
 kill -9 "$(< LOCAL_DMEVENTD)"
@@ -49,11 +52,14 @@ sleep 9
 not pgrep dmeventd
 rm LOCAL_DMEVENTD
 
+check lv_field $vg/3way seg_monitor "not monitored"
+check lv_field $vg/4way seg_monitor "not monitored"
+
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 pgrep -o dmeventd >LOCAL_DMEVENTD
-not grep 'already monitored' lvchange.out
+test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 
 lvchange --monitor y --verbose $vg/$lv2 2>&1 | tee lvchange.out
-not grep 'already monitored' lvchange.out
+test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 
 vgremove -ff $vg


