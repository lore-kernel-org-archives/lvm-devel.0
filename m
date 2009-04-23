From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Apr 2009 12:20:16 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20090423122016.13219.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-04-23 12:20:15

Modified files:
	man            : dmsetup.8.in 

Log message:
	fix typo reported by "A. Costa" <agcosta@gis.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/man/dmsetup.8.in	2007/12/28 15:13:38	1.22
+++ LVM2/man/dmsetup.8.in	2009/04/23 12:20:15	1.23
@@ -232,7 +232,7 @@
 .br
 Attempts to remove all device definitions i.e. reset the driver.
 Use with care!  From version 4.8.0 onwards, if devices can't
-be removed because uninterruptible processess are waiting for
+be removed because uninterruptible processes are waiting for
 I/O to return from them, adding --force will replace the table 
 with one that fails all I/O, which might allow the 
 process to be killed.  This also runs \fBmknodes\fP afterwards.


