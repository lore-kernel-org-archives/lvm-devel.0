From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 May 2010 16:33:22 -0000
Subject: LVM2/test t-lvconvert-repair-transient.sh
Message-ID: <20100524163322.28557.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-24 16:33:21

Modified files:
	test           : t-lvconvert-repair-transient.sh 

Log message:
	t-lvconvert-repair-transient hangs on .33 and on RHEL6 kernel -> disable

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-lvconvert-repair-transient.sh	2010/05/24 15:32:21	1.1
+++ LVM2/test/t-lvconvert-repair-transient.sh	2010/05/24 16:33:21	1.2
@@ -13,6 +13,8 @@
 
 prepare_vg 5
 
+exit 200 # this breaks upstream .33 and RHEL6 kernel :(
+
 # fail multiple devices
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg


