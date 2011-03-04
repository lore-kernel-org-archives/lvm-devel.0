From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Mar 2011 15:04:09 -0000
Subject: LVM2/test t-lock-blocking.sh
Message-ID: <20110304150409.389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-04 15:04:08

Modified files:
	test           : t-lock-blocking.sh 

Log message:
	Make the lock test a little bit better...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lock-blocking.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-lock-blocking.sh	2011/03/03 16:04:53	1.5
+++ LVM2/test/t-lock-blocking.sh	2011/03/04 15:04:08	1.6
@@ -21,17 +21,21 @@
 # if wait_for_locks set, vgremove should wait for orphan lock
 # flock process should have exited by the time first vgremove completes
 flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
-flock_pid=`jobs -p`
+while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
+
 vgremove --config 'global { wait_for_locks = 1 }' $vg
 not vgremove --config 'global { wait_for_locks = 1 }' $vg
-sleep .2 # leave some time for scheduler to exit flock process
-not ps $flock_pid # finished
+
+test ! -f $TESTDIR/var/lock/lvm/P_orphans
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
 vgcreate $vg $dev1 $dev2
 flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+
+while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
 flock_pid=`jobs -p`
+
 not vgremove --config 'global { wait_for_locks = 0 }' $vg
-ps $flock_pid # still running
+test -f $TESTDIR/var/lock/lvm/P_orphans # still running
 kill $flock_pid


