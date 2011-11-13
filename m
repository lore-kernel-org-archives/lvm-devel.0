From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Nov 2011 01:41:57 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20111113014157.1217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-13 01:41:57

Modified files:
	man            : dmsetup.8.in 

Log message:
	Incomplete documentation is worse than no documentation.
	Any documentation less-detailed than Documentation/device-mapper is
	dangerous for the non-trivial ctr lines.  And anyway, this should be in s4
	not here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/man/dmsetup.8.in	2011/11/12 22:48:44	1.45
+++ LVM2/man/dmsetup.8.in	2011/11/13 01:41:57	1.46
@@ -532,6 +532,7 @@
 To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
 .SH TABLE FORMAT
+// FIXME Rewrite safely (a lot of work) or remove.
 Each line of the table specifies a single target and is of the form:
 .P
 .I logical_start_sector num_sectors


