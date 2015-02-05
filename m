From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:43 +0000 (UTC)
Subject: master - NIX: Update path to /xchg (was /tmp/xchg with older nixpkgs).
Message-ID: <20150205134243.73AE1601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68f7b422c10cc0c042d74ceac4bf9a27c625a99c
Commit:        68f7b422c10cc0c042d74ceac4bf9a27c625a99c
Parent:        f1d273a0b09cf2de58921dbf72459fe16b3b6c6a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Sep 13 17:53:42 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Update path to /xchg (was /tmp/xchg with older nixpkgs).

---
 nix/default.nix |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 96ad775..d023f6e 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -42,7 +42,7 @@ let
             url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
             sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
 
-         mkdir -p /tmp/xchg/results
+         mkdir -p /xchg/results
 
          dmsetup targets
 
@@ -51,12 +51,12 @@ let
          watch=
          if echo ${flavour} | grep -q udev; then
            (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
-            find / -xdev -name \*udevd) >> /tmp/xchg/udevd.log 2>&1 &
-           watch="--watch /tmp/xchg/udevd.log"
+            find / -xdev -name \*udevd) >> /xchg/udevd.log 2>&1 &
+           watch="--watch /xchg/udevd.log"
          fi
 
-         lvm2-testsuite --batch --outdir /tmp/xchg/results --continue \
-             --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
+         lvm2-testsuite --batch --outdir /xchg/results --continue \
+             --fatal-timeouts --heartbeat /xchg/heartbeat \
              --flavours ${flavour} $watch --kmsg ${if lib.eqStrings T "" then "" else "--only ${T}"}
 
          # TODO: coverage reports


