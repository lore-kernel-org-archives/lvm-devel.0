From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:37 +0000 (UTC)
Subject: master - NIX: Add --kmsg to lvm2-testsuite invocations.
Message-ID: <20150205134237.2AB9F601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=003bf24723624fcb6b10e3eec5a7b5bf5265b498
Commit:        003bf24723624fcb6b10e3eec5a7b5bf5265b498
Parent:        7ed8fc8f7d007ac8c2ad77e4c6799056490329bc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 22 18:44:53 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Add --kmsg to lvm2-testsuite invocations.

---
 nix/default.nix |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 2ab5978..184fe96 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -32,14 +32,15 @@ let
 
          lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
              --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
-             --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
+             --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad \
+             --kmsg
 
          (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
              find / -xdev -name \*udevd) >> /tmp/xchg/udevd.log 2>&1 &
          lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
              --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
              --flavours udev-vanilla,udev-cluster,udev-lvmetad \
-             --watch /tmp/xchg/udevd.log
+             --watch /tmp/xchg/udevd.log --kmsg
 
          # if we made it this far, all test results are in
 


