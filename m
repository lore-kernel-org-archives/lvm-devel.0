From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:54 +0000 (UTC)
Subject: master - NIX: Use --batch mode for running the testsuite.
Message-ID: <20150205134154.BE2996052F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dcf5182a96c7eb65fe5d61ce5ceea9ba5bf7a3f2
Commit:        dcf5182a96c7eb65fe5d61ce5ceea9ba5bf7a3f2
Parent:        4b5ae314049cebbd1b4f6ad35fd11d957a50db8e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:09:02 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Use --batch mode for running the testsuite.

---
 nix/default.nix |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 2ea248e..bd3d969 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -28,14 +28,14 @@ let
 
          export LVM_TEST_BACKING_DEVICE=/dev/vdb
          if ! test -e /tmp/xchg/results-ndev/list; then
-             lvm2-testsuite --outdir /tmp/xchg/results-ndev --continue \
+             lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
                  --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
          fi
 
          if ! test -e /tmp/xchg/results-udev/list; then
              (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
                  find / -xdev -name \*udevd) &
-             lvm2-testsuite --outdir /tmp/xchg/results-udev --continue \
+             lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
                  --flavours udev-vanilla,udev-cluster,udev-lvmetad
          fi
 


