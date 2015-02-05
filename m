From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:58 +0000 (UTC)
Subject: master - NIX: Adapt to the append-based test journal.
Message-ID: <20150205134158.F2CCA6036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b6f9152ccbc74ab4c599089dc6bf0ae43ccd123
Commit:        2b6f9152ccbc74ab4c599089dc6bf0ae43ccd123
Parent:        285db7a240229e17fabaaf03ad9febd90afe8a8e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Jun 28 11:16:22 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Adapt to the append-based test journal.

---
 nix/default.nix |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 9b466ba..843440e 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -16,7 +16,7 @@ let
          #!/bin/bash
          export PATH=/usr/bin:/bin:/usr/sbin:/sbin
 
-	 # we always run in a fresh image, so need to install everything again
+         # we always run in a fresh image, so need to install everything again
          ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uvh # */
          rpm -Uv ${pkgs.fetchurl {
             url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
@@ -72,8 +72,9 @@ let
        monitor() {
            set +e
            counter=0
+           rm -f j.current j.last t.current t.last
            while true; do
-               cat xchg/results-ndev/journal* xchg/results-udev/journal* > j.current 2> /dev/null
+               cat xchg/results-ndev/journal xchg/results-udev/journal > j.current 2> /dev/null
                cat xchg/results-ndev/timestamp xchg/results-udev/timestamp > t.current 2> /dev/null
                # the journal didn't change for 10 minutes, kill the VM
                if diff j.current j.last > /dev/null 2> /dev/null; then
@@ -95,6 +96,7 @@ let
            ${vmtools.qemu}/bin/qemu-img create -f qcow2 /dev/shm/testdisk.img 4G
            setsid bash -e ${vmtools.vmRunCommand (vmtools.qemuCommandLinux kernel)} &
            pid=$!
+           sleep 60 # give the VM some time to get up and running
            monitor $pid &
            mon=$!
 
@@ -112,8 +114,7 @@ let
            sleep 5 # wait for the VM to clean up before starting up a new one
        done
 
-       # (ab)use the journals in case the lists weren't actually written yet
-       cat xchg/results-ndev/journal xchg/results-udev/journal > $out/test-results/list || true
+       cat xchg/results-ndev/list xchg/results-udev/list > $out/test-results/list || true
      '';
   };
 


