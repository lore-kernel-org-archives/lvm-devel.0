From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:03:24 -0000
Subject: LVM2/lib/format1 disk-rep.c
Message-ID: <20080919070324.22699.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:03:23

Modified files:
	lib/format1    : disk-rep.c 

Log message:
	revert unexplained removal of a '<backtrace>' message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/format1/disk-rep.c	2008/09/15 17:06:54	1.75
+++ LVM2/lib/format1/disk-rep.c	2008/09/19 07:03:23	1.76
@@ -356,7 +356,7 @@
 	list_init(&dl->lvds);
 
 	if (!_read_pvd(dev, &dl->pvd))
-		goto bad;
+		goto_bad;
 
 	/*
 	 * is it an orphan ?


