From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:32 +0000 (UTC)
Subject: master - NIX: Keep the udev log out of tmpfs.
Message-ID: <20150205134232.DA40F601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9df76f8b3f322f0fcefcc6861796476af1bbb18
Commit:        f9df76f8b3f322f0fcefcc6861796476af1bbb18
Parent:        e2dbf441165f998cf2adf96995a58e978e0c9473
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 22 11:46:19 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Keep the udev log out of tmpfs.

---
 nix/default.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 20922b8..2ab5978 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -35,11 +35,11 @@ let
              --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
 
          (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
-             find / -xdev -name \*udevd) >& /tmp/udevd.log &
+             find / -xdev -name \*udevd) >> /tmp/xchg/udevd.log 2>&1 &
          lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
              --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
              --flavours udev-vanilla,udev-cluster,udev-lvmetad \
-             --watch /tmp/udevd.log
+             --watch /tmp/xchg/udevd.log
 
          # if we made it this far, all test results are in
 


