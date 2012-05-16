From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 May 2012 15:01:07 -0000
Subject: LVM2/test/shell snapshots-of-mirrors.sh
Message-ID: <20120516150107.20565.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-16 15:01:06

Modified files:
	test/shell     : snapshots-of-mirrors.sh 

Log message:
	snaps of mirrors are enabled

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/shell/snapshots-of-mirrors.sh	2012/05/01 19:21:25	1.3
+++ LVM2/test/shell/snapshots-of-mirrors.sh	2012/05/16 15:01:06	1.4
@@ -15,7 +15,8 @@
 
 # Attempt to create snapshot of a mirror origin - should fail
 lvcreate -m 1 -L 10M -n lv $vg
-not lvcreate -s $vg/lv -L 10M -n snap
+
+lvcreate -s $vg/lv -L 10M -n snap
 
 exit 0
 


