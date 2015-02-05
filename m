From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:05 +0000 (UTC)
Subject: master - NIX: Existence of results list no longer indicates that the suite has finished.
Message-ID: <20150205134205.54B896036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0abad40f416a3831c9e4b44924468bd7b591a4fa
Commit:        0abad40f416a3831c9e4b44924468bd7b591a4fa
Parent:        e3ac180ab37a5cfe39ac739d48b9176c0e4f6003
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Jun 28 12:51:18 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Existence of results list no longer indicates that the suite has finished.

---
 nix/default.nix |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 8de3eba..55ad8e1 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -27,17 +27,14 @@ let
          dmsetup targets
 
          export LVM_TEST_BACKING_DEVICE=/dev/vdb
-         if ! test -e /tmp/xchg/results-ndev/list; then
-             lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
-                 --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
-         fi
-
-         if ! test -e /tmp/xchg/results-udev/list; then
-             (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
-                 find / -xdev -name \*udevd) &
-             lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
-                 --flavours udev-vanilla,udev-cluster,udev-lvmetad
-         fi
+
+         lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
+             --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
+
+         (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
+             find / -xdev -name \*udevd) >& /tmp/udevd.log &
+         lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
+             --flavours udev-vanilla,udev-cluster,udev-lvmetad --watch /tmp/udevd.log
 
          # if we made it this far, all test results are in
 


