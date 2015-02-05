From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:39 +0000 (UTC)
Subject: master - NIX: Run each test flavour as a separate derivation.
Message-ID: <20150205134239.3CE53601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93d8455faac76f5dcbf40f45d28aaf506856eb85
Commit:        93d8455faac76f5dcbf40f45d28aaf506856eb85
Parent:        003bf24723624fcb6b10e3eec5a7b5bf5265b498
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 29 14:30:22 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Run each test flavour as a separate derivation.

---
 nix/default.nix |   49 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 184fe96..6cadd32 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -9,9 +9,27 @@
 let
   pkgs = import nixpkgs {};
   lib = pkgs.lib;
-  mkTest = { build, diskFun, extras ? [], kernel, vmtools, ... }: pkgs.stdenv.mkDerivation rec {
+
+  mkTest = args: pkgs.stdenv.mkDerivation rec {
+     name = "lvm2-test-${(args.diskFun {}).name}";
+
+     builder = pkgs.writeScript "lvm2-collect-results" ''
+       #!${pkgs.bash}/bin/bash
+       . $stdenv/setup
+       mkdir -p $out/test-results
+       for i in ${lib.concatStringsSep " " buildInputs}; do
+         cat $i/test-results/list >> $out/test-results/list
+         cp $i/test-results'/'*.txt $out/test-results/
+       done
+     '';
+
+     buildInputs = map (x: runTest (args // { flavour = x; }))
+       [ "ndev-vanilla" "ndev-lvmetad" "ndev-cluster" "udev-vanilla" "udev-lvmetad" "udev-cluster" ];
+  };
+
+  runTest = { build, diskFun, extras ? [], kernel, vmtools, flavour, ... }: pkgs.stdenv.mkDerivation rec {
      diskImage = diskFun { extraPackages = extras; };
-     name = "lvm2-test-${diskImage.name}";
+     name = "lvm2-test-${diskImage.name}-${flavour}";
 
      # this is the builder that runs in the guest
      origBuilder = pkgs.writeScript "vm-test-guest" ''
@@ -24,25 +42,22 @@ let
             url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
             sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
 
-         mkdir -p /tmp/xchg/results-{udev,ndev}
+         mkdir -p /tmp/xchg/results
 
          dmsetup targets
 
          export LVM_TEST_BACKING_DEVICE=/dev/sdb
 
-         lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
-             --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
-             --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad \
-             --kmsg
+         watch=
+         if echo ${flavour} | grep -q udev; then
+           (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
+            find / -xdev -name \*udevd) >> /tmp/xchg/udevd.log 2>&1 &
+           watch="--watch /tmp/xchg/udevd.log"
+         fi
 
-         (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
-             find / -xdev -name \*udevd) >> /tmp/xchg/udevd.log 2>&1 &
-         lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
+         lvm2-testsuite --batch --outdir /tmp/xchg/results --continue \
              --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
-             --flavours udev-vanilla,udev-cluster,udev-lvmetad \
-             --watch /tmp/xchg/udevd.log --kmsg
-
-         # if we made it this far, all test results are in
+             --flavours ${flavour} $watch --kmsg ${if lib.eqStrings T "" then "" else "--only ${T}"}
 
          # TODO: coverage reports
          # make lcov || true
@@ -84,7 +99,7 @@ let
                    continue
                fi
 
-               cat xchg/results-ndev/journal xchg/results-udev/journal > j.current 2> /dev/null
+               cat xchg/results/journal > j.current 2> /dev/null
                cat xchg/heartbeat > hb.current 2> /dev/null
                if diff j.current j.last >& /dev/null; then
                    counter=$(($counter + 1));
@@ -116,7 +131,7 @@ let
            rm -f pid # disarm the monitor process
 
            # if we have any new results, stash them
-           mv xchg/results-*'/'*.txt $out/test-results/ || true
+           mv xchg/results'/'*.txt $out/test-results/ || true
 
            if test -n "$(cat xchg/in-vm-exit)"; then # the VM is done
                test 0 -eq "$(cat xchg/in-vm-exit)" && rm -f $out/nix-support/failed
@@ -126,7 +141,7 @@ let
            sleep 10 # wait for the VM to clean up before starting up a new one
        done
 
-       cat xchg/results-ndev/list xchg/results-udev/list > $out/test-results/list || true
+       cat xchg/results/list > $out/test-results/list || true
      '';
   };
 


