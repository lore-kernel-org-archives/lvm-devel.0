From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:02 +0000 (UTC)
Subject: master - NIX: Detect that the VM booted up more directly.
Message-ID: <20150205134302.6CF1460E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3cc6576ee065b02ff58974f0f0e8792dffbd824
Commit:        f3cc6576ee065b02ff58974f0f0e8792dffbd824
Parent:        734a183c5658c1f305a375da02bb24cccad566df
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 11:02:25 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

NIX: Detect that the VM booted up more directly.

---
 nix/default.nix |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 734fb3b..5999bd2 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -45,6 +45,7 @@ let
             sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
 
          mkdir -p /xchg/results
+         touch /xchg/booted
 
          dmsetup targets
 
@@ -123,11 +124,17 @@ let
        monitor &
 
        for i in `seq 1 20`; do # we allow up to 20 VM restarts
+           rm -f xchg/booted
            ${vmtools.qemu}/bin/qemu-img create -f qcow2 /dev/shm/testdisk.img 4G
            setsid bash -e ${vmtools.vmRunCommand (vmtools.qemuCommandLinux kernel)} &
            pid=$!
 
-           sleep 180 # give the VM some time to get up and running
+           # give the VM some time to get up and running
+           slept=0
+           while test $slept -le 180 && test ! -e xchg/booted; do
+               sleep 10
+               slept=$(($slept + 10))
+           done
            echo $pid > pid # monitor go
            wait $pid || true
            rm -f pid # disarm the monitor process


