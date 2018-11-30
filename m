From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 07:11:01 -0500
Subject: master - tests: extend sleep
Message-ID: <201811301211.wAUCB17x014610@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c0c318e4f2ea362a4eb0207ee7b77ef2d8425dc5
Commit:        c0c318e4f2ea362a4eb0207ee7b77ef2d8425dc5
Parent:        8b87ffaa8a273ee7870298d9f74f0fabbf160148
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 12:55:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 30 13:03:09 2018 +0100

tests: extend sleep

---
 test/shell/dmeventd-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 65f1655..5267290 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -44,7 +44,7 @@ dmeventd -R -f &
 echo $! >LOCAL_DMEVENTD
 
 # wait longer as tries to communicate with killed daemon
-sleep 7
+sleep 9
 # now dmeventd should not be running
 not pgrep dmeventd
 rm LOCAL_DMEVENTD


