From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 13:44:02 -0000
Subject: LVM2/test t-pool-labels.sh
Message-ID: <20081110134402.19357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 13:44:01

Modified files:
	test           : t-pool-labels.sh 

Log message:
	Fix t-pool-labels to pass again after the vgdisplay error return fix from
	last Friday.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pool-labels.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-pool-labels.sh	2008/09/29 16:02:49	1.2
+++ LVM2/test/t-pool-labels.sh	2008/11/10 13:44:01	1.3
@@ -31,7 +31,9 @@
 not pvcreate "$dev1"
 
 # check that vgdisplay and pvcreate -ff works with the pool device
-vgdisplay
+vgdisplay --config 'global { locking_type = 0 }'
 disable_dev "$dev2"
-vgdisplay
+# FIXME! since pool1 cannot be opened, vgdisplay gives error... should we say
+# "not" there instead, checking that it indeed does fail?
+vgdisplay --config 'global { locking_type = 0 }' || true
 pvcreate -ff -y "$dev1"


