From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:06 +0000 (UTC)
Subject: master - test: Avoid passing -c to flock.
Message-ID: <20150205134306.A187560E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=580370bea3a149afaffd9cfeeefb93b20c69c71f
Commit:        580370bea3a149afaffd9cfeeefb93b20c69c71f
Parent:        7a0aa25c28ccb89834a83b06917be803713b4804
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 16:32:11 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

test: Avoid passing -c to flock.

---
 test/shell/lock-blocking.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index e05fa50..7c33067 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -20,7 +20,7 @@ vgcreate $vg "$dev1" "$dev2"
 
 # if wait_for_locks set, vgremove should wait for orphan lock
 # flock process should have exited by the time first vgremove completes
-flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+flock -w 5 $TESTDIR/var/lock/lvm/P_orphans sleep 10 &
 while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
 
 vgremove --config 'global { wait_for_locks = 1 }' $vg
@@ -31,7 +31,7 @@ test ! -f $TESTDIR/var/lock/lvm/P_orphans
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
 vgcreate $vg "$dev1" "$dev2"
-flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+flock -w 5 $TESTDIR/var/lock/lvm/P_orphans sleep 10 &
 
 while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
 flock_pid=`jobs -p`


