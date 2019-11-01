From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:26:15 -0400
Subject: stable-2.02 - tests: avoid checking command result in cluster
Message-ID: <201911011526.xA1FQFsZ016341@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df00a62fd0a4a4f8a57ac34a80b37ddfb6e98d74
Commit:        df00a62fd0a4a4f8a57ac34a80b37ddfb6e98d74
Parent:        796efef15e048abe4122e7348b22b45d0b73b5bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 15:46:16 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 15:56:03 2019 +0100

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
index 65f1655..7d1d253 100644
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
@@ -49,11 +52,14 @@ sleep 7
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


