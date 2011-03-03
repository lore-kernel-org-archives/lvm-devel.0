From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Mar 2011 16:04:54 -0000
Subject: LVM2/test t-lock-blocking.sh
Message-ID: <20110303160454.10504.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-03 16:04:54

Modified files:
	test           : t-lock-blocking.sh 

Log message:
	Leave some time to scheduler
	
	Looks like scheduler prefers running task before exiting tasks.
	So leave some time to finish running flock process.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lock-blocking.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-lock-blocking.sh	2011/01/13 11:05:27	1.4
+++ LVM2/test/t-lock-blocking.sh	2011/03/03 16:04:53	1.5
@@ -24,6 +24,7 @@
 flock_pid=`jobs -p`
 vgremove --config 'global { wait_for_locks = 1 }' $vg
 not vgremove --config 'global { wait_for_locks = 1 }' $vg
+sleep .2 # leave some time for scheduler to exit flock process
 not ps $flock_pid # finished
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock


