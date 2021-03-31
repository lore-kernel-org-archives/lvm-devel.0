From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:20 +0000 (GMT)
Subject: dev-next - tests: move setting of dmeventd pid
Message-ID: <20210331214920.28B6C3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ed79d8dfe8b75830d8fd6925d7cef5ef1ebd8f2
Commit:        3ed79d8dfe8b75830d8fd6925d7cef5ef1ebd8f2
Parent:        85fae836c09daf457f3f8f14e3eae2179cfd2ffa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 11:16:32 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 11:16:32 2021 +0100

tests: move setting of dmeventd pid

Added comment the  'lvs' already initiates dmeventd

Note: we don't have any query mechanism to check if dmeventd
is already running except access of socket which basically
starts dmeventd if it's not running.
---
 test/shell/dmeventd-restart.sh | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 151f1d51a..0def8c1fa 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -41,7 +41,7 @@ test -e LOCAL_CLVMD || grep 'already monitored' lvchange.out
 
 # now try what happens if no dmeventd is running
 kill -9 "$(< LOCAL_DMEVENTD)"
-rm LOCAL_DMEVENTD
+rm LOCAL_DMEVENTD debug.log*
 
 dmeventd -R -f &
 echo $! >LOCAL_DMEVENTD
@@ -52,11 +52,12 @@ sleep 9
 not pgrep dmeventd
 rm LOCAL_DMEVENTD
 
+# First lvs restarts 'dmeventd' (initiate a socket connection to a daemon)
 check lv_field $vg/3way seg_monitor "not monitored"
+pgrep -o dmeventd >LOCAL_DMEVENTD
 check lv_field $vg/4way seg_monitor "not monitored"
 
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
-pgrep -o dmeventd >LOCAL_DMEVENTD
 test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 
 lvchange --monitor y --verbose $vg/$lv2 2>&1 | tee lvchange.out


