From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:17 +0000 (UTC)
Subject: master - NIX: Pass --fatal-timeouts to the testsuite.
Message-ID: <20150205134217.D1C626036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f28407943f88a12de3678ad7af302bccf8bf324e
Commit:        f28407943f88a12de3678ad7af302bccf8bf324e
Parent:        eec99ffa8c953883c7c22e9e39a42a63b452d611
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jul 4 09:45:56 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Pass --fatal-timeouts to the testsuite.

---
 nix/default.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 19df6e8..a387fcb 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -31,12 +31,12 @@ let
          export LVM_TEST_BACKING_DEVICE=/dev/vdb
 
          lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
-             --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
+             --fatal-timeouts --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
 
          (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
              find / -xdev -name \*udevd) >& /tmp/udevd.log &
          lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
-             --flavours udev-vanilla,udev-cluster,udev-lvmetad --watch /tmp/udevd.log
+             --fatal-timeouts --flavours udev-vanilla,udev-cluster,udev-lvmetad --watch /tmp/udevd.log
 
          # if we made it this far, all test results are in
 


