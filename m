From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Apr 2018 04:43:02 -0400
Subject: master - tests: add also snapshot monitoring
Message-ID: <201804300843.w3U8h22B017324@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b904d6653dcecb83a5404a89d00bdd6750cea568
Commit:        b904d6653dcecb83a5404a89d00bdd6750cea568
Parent:        fade45b1d14c90eac7c6cc41019ef946659a8fb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 28 22:18:00 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 30 10:41:51 2018 +0200

tests: add also snapshot monitoring

---
 test/shell/dmeventd-restart.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 87e3e40..58575fc 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -24,6 +24,9 @@ lvchange --monitor y $vg/4way
 lvcreate -aey --type mirror -m 2 --nosync --ignoremonitoring -l1 -n 3way $vg
 lvchange --monitor y $vg/3way
 
+lvcreate -aey -l1 -n $lv1 $vg
+lvcreate -s -l1 -n $lv2 $vg/$lv1
+
 dmeventd -R -f &
 echo $! >LOCAL_DMEVENTD
 sleep 2 # wait a bit, so we talk to the new dmeventd later
@@ -50,4 +53,7 @@ lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 pgrep -o dmeventd >LOCAL_DMEVENTD
 not grep 'already monitored' lvchange.out
 
+lvchange --monitor y --verbose $vg/$lv2 2>&1 | tee lvchange.out
+not grep 'already monitored' lvchange.out
+
 vgremove -ff $vg


