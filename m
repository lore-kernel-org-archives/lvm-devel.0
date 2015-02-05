From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:09 +0000 (UTC)
Subject: master - NIX: Re-work VM monitoring.
Message-ID: <20150205134209.7A0506036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa2e84caa80053dbc5a8b42d2d3e2e1492736243
Commit:        fa2e84caa80053dbc5a8b42d2d3e2e1492736243
Parent:        f96c310eea7e4f6a6cc567e2f5b52a2d1f5f4c90
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 29 17:37:35 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Re-work VM monitoring.

---
 nix/default.nix |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index c73ec29..19df6e8 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -1,3 +1,4 @@
+# -*- mode: nix; indent-tabs-mode: nil -*-
 { nixpkgs ? <nixpkgs>, lvm2Src, release ? false,
   rawhide32 ? "" , rawhide64 ? "" ,
   fc20_32_updates ? "", fc20_64_updates ? "",
@@ -72,34 +73,42 @@ let
            counter=0
            rm -f j.current j.last t.current t.last
            while true; do
+               if ! test -f pid; then
+                   counter=0
+                   sleep 60
+                   continue
+               fi
+
                cat xchg/results-ndev/journal xchg/results-udev/journal > j.current 2> /dev/null
                cat xchg/results-ndev/timestamp xchg/results-udev/timestamp > t.current 2> /dev/null
-               # the journal didn't change for 10 minutes, kill the VM
-               if diff j.current j.last > /dev/null 2> /dev/null; then
+               if diff j.current j.last >& /dev/null; then
                    counter=$(($counter + 1));
                else
                    counter=0
                fi
-               if test $counter -eq 10 || diff t.current t.last > /dev/null 2> /dev/null; then
-                   kill $1
-                   sleep 3600 # wait for the parent to kill us
+               if test $counter -eq 10 || diff t.current t.last >& /dev/null; then
+                   echo
+                   echo "VM got stuck; timestamps: $(cat t.current) $(cat t.last), counter = $counter."
+                   echo "last journal entry: $(tail -n 1 j.current), previously $(tail -n 1 j.last)"
+                   kill -- -$(cat pid)
                fi
                sleep 60
-               mv j.current j.last
-               mv t.current t.last
+               mv j.current j.last >& /dev/null
+               mv t.current t.last >& /dev/null
            done
        }
 
-       for i in seq 1 20; do # we allow up to 20 VM restarts
+       monitor &
+
+       for i in `seq 1 20`; do # we allow up to 20 VM restarts
            ${vmtools.qemu}/bin/qemu-img create -f qcow2 /dev/shm/testdisk.img 4G
            setsid bash -e ${vmtools.vmRunCommand (vmtools.qemuCommandLinux kernel)} &
            pid=$!
-           sleep 60 # give the VM some time to get up and running
-           monitor $pid &
-           mon=$!
 
+           sleep 180 # give the VM some time to get up and running
+           echo $pid > pid # monitor go
            wait $pid || true
-           kill $mon
+           rm -f pid # disarm the monitor process
 
            # if we have any new results, stash them
            mv xchg/results-*'/'*.txt $out/test-results/ || true
@@ -109,7 +118,7 @@ let
                break
            fi
 
-           sleep 5 # wait for the VM to clean up before starting up a new one
+           sleep 10 # wait for the VM to clean up before starting up a new one
        done
 
        cat xchg/results-ndev/list xchg/results-udev/list > $out/test-results/list || true


