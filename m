From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 12 Apr 2011 21:21:08 -0000
Subject: LVM2/man lvm.conf.5.in
Message-ID: <20110412212108.27856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-04-12 21:21:08

Modified files:
	man            : lvm.conf.5.in 

Log message:
	fix s/then/than/ typo in lvm.conf.5.in

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/man/lvm.conf.5.in	2011/03/10 15:20:10	1.17
+++ LVM2/man/lvm.conf.5.in	2011/04/12 21:21:08	1.18
@@ -175,8 +175,8 @@
 \fBpv_min_size\fP \(em
 Minimal size (in KB) of the block device which can be used as a PV.
 In clustered environment all nodes have to use the same value.
-Any value smaller then 512KB is ignored. An example to
-ignore devices smaller then 2MB (i.e. floppy drives):
+Any value smaller than 512KB is ignored.  An example to
+ignore devices smaller than 2MB (i.e. floppy drives):
 .IP
 pv_min_size = 2048
 .IP


