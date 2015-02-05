From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:22 +0000 (UTC)
Subject: master - NIX: Use the new --heartbeat option on lvm2-testsuite.
Message-ID: <20150205134222.09BC76036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9dfc5f8a4e50bf78e6c9d01266482ddbd33dda8
Commit:        f9dfc5f8a4e50bf78e6c9d01266482ddbd33dda8
Parent:        8646b50aa90cdde418ba336eb20a2799d09024b3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jul 4 18:28:10 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Use the new --heartbeat option on lvm2-testsuite.

---
 nix/default.nix |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index a387fcb..809debe 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -31,12 +31,15 @@ let
          export LVM_TEST_BACKING_DEVICE=/dev/vdb
 
          lvm2-testsuite --batch --outdir /tmp/xchg/results-ndev --continue \
-             --fatal-timeouts --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
+             --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
+             --flavours ndev-vanilla,ndev-cluster,ndev-lvmetad
 
          (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || \
              find / -xdev -name \*udevd) >& /tmp/udevd.log &
          lvm2-testsuite --batch --outdir /tmp/xchg/results-udev --continue \
-             --fatal-timeouts --flavours udev-vanilla,udev-cluster,udev-lvmetad --watch /tmp/udevd.log
+             --fatal-timeouts --heartbeat /tmp/xchg/heartbeat \
+             --flavours udev-vanilla,udev-cluster,udev-lvmetad \
+             --watch /tmp/udevd.log
 
          # if we made it this far, all test results are in
 
@@ -80,21 +83,21 @@ let
                fi
 
                cat xchg/results-ndev/journal xchg/results-udev/journal > j.current 2> /dev/null
-               cat xchg/results-ndev/timestamp xchg/results-udev/timestamp > t.current 2> /dev/null
+               cat xchg/heartbeat > hb.current 2> /dev/null
                if diff j.current j.last >& /dev/null; then
                    counter=$(($counter + 1));
                else
                    counter=0
                fi
-               if test $counter -eq 10 || diff t.current t.last >& /dev/null; then
+               if test $counter -eq 10 || test $(cat hb.current | wc -c) -eq $(cat hb.last | wc -c); then
                    echo
-                   echo "VM got stuck; timestamps: $(cat t.current) $(cat t.last), counter = $counter."
+                   echo "VM got stuck; heartbeat: $(cat hb.current | wc -c) $(cat hb.last | wc -c), counter = $counter."
                    echo "last journal entry: $(tail -n 1 j.current), previously $(tail -n 1 j.last)"
                    kill -- -$(cat pid)
                fi
                sleep 60
                mv j.current j.last >& /dev/null
-               mv t.current t.last >& /dev/null
+               mv hb.current hb.last >& /dev/null
            done
        }
 


