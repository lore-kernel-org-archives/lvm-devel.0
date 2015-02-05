From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:56 +0000 (UTC)
Subject: master - NIX: Implement a smarter VM monitoring loop.
Message-ID: <20150205134156.D74996052F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=285db7a240229e17fabaaf03ad9febd90afe8a8e
Commit:        285db7a240229e17fabaaf03ad9febd90afe8a8e
Parent:        dcf5182a96c7eb65fe5d61ce5ceea9ba5bf7a3f2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:09:30 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Implement a smarter VM monitoring loop.

---
 nix/default.nix |   48 ++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index bd3d969..9b466ba 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -61,30 +61,58 @@ let
      builder = pkgs.writeScript "vm-test" ''
        #!${pkgs.bash}/bin/bash
        . $stdenv/setup
-       set -x
 
        export QEMU_OPTS="-drive file=/dev/shm/testdisk.img,if=virtio -m 256M"
-       export KERNEL_OPTS="log_buf_len=131072"
+       export KERNEL_OPTS="log_buf_len=131072 loglevel=1"
        export mountDisk=1
 
        mkdir -p $out/test-results $out/nix-support
        touch $out/nix-support/failed
 
-       # give it 9x 20 minutes, i.e. about 3 hours
-       for i in seq 1 9; do
+       monitor() {
+           set +e
+           counter=0
+           while true; do
+               cat xchg/results-ndev/journal* xchg/results-udev/journal* > j.current 2> /dev/null
+               cat xchg/results-ndev/timestamp xchg/results-udev/timestamp > t.current 2> /dev/null
+               # the journal didn't change for 10 minutes, kill the VM
+               if diff j.current j.last > /dev/null 2> /dev/null; then
+                   counter=$(($counter + 1));
+               else
+                   counter=0
+               fi
+               if test $counter -eq 10 || diff t.current t.last > /dev/null 2> /dev/null; then
+                   kill $1
+                   sleep 3600 # wait for the parent to kill us
+               fi
+               sleep 60
+               mv j.current j.last
+               mv t.current t.last
+           done
+       }
+
+       for i in seq 1 20; do # we allow up to 20 VM restarts
            ${vmtools.qemu}/bin/qemu-img create -f qcow2 /dev/shm/testdisk.img 4G
            setsid bash -e ${vmtools.vmRunCommand (vmtools.qemuCommandLinux kernel)} &
            pid=$!
-           ( sleep 1200 ; kill -- -$pid ) &
-           if wait $pid; then
-               rm -f $out/nix-support/failed
+           monitor $pid &
+           mon=$!
+
+           wait $pid || true
+           kill $mon
+
+           # if we have any new results, stash them
+           mv xchg/results-*'/'*.txt $out/test-results/ || true
+
+           if test -n "$(cat xchg/in-vm-exit)"; then # the VM is done
+               test 0 -eq "$(cat xchg/in-vm-exit)" && rm -f $out/nix-support/failed
                break
            fi
-           mv xchg/results-*'/'*.txt $out/test-results/
-           sleep 5
+
+           sleep 5 # wait for the VM to clean up before starting up a new one
        done
 
-       # use journals in case the lists weren't actually written yet
+       # (ab)use the journals in case the lists weren't actually written yet
        cat xchg/results-ndev/journal xchg/results-udev/journal > $out/test-results/list || true
      '';
   };


