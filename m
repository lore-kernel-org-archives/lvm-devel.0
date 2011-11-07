From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Nov 2011 17:11:24 -0000
Subject: LVM2/daemons/clvmd clvmd-singlenode.c
Message-ID: <20111107171124.22494.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-07 17:11:23

Modified files:
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Correctly handle concurrent read (CR) locks in singlenode clvmd. This means
	that we can also test clustered volume groups (vgcreate -c y) in the test
	suite. Unfortunately we can't make this the testing default since cluster
	mirrors require further infrastructure, and snapshots probably don't work at
	all. I'll eventually add a few test cases that create clustered VGs
	specifically.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/daemons/clvmd/clvmd-singlenode.c	2011/10/11 09:05:20	1.14
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2011/11/07 17:11:23	1.15
@@ -157,6 +157,13 @@
 	char **_resources_1;
 	int i, j;
 
+	if (mode == LCK_READ) { /* only track PREAD, aka PROTECTED READ */
+		DEBUGLOG("Not tracking CONCURRENT READ lock: %s, flags=%d, mode=%d\n",
+			 resource, flags, mode);
+		*lockid = -1;
+		return 0;
+	}
+
 	DEBUGLOG("Locking resource %s, flags=%d, mode=%d\n",
 		 resource, flags, mode);
 
@@ -224,6 +231,12 @@
 
 static int _unlock_resource(const char *resource, int lockid)
 {
+	if (lockid < 0) {
+		DEBUGLOG("Not tracking unlock of lockid -1: %s, lockid=%d\n",
+			 resource, lockid);
+		return 0;
+	}
+
 	DEBUGLOG("Unlocking resource %s, lockid=%d\n", resource, lockid);
 	pthread_mutex_lock(&_lock_mutex);
 


