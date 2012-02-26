From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Feb 2012 08:45:10 -0000
Subject: LVM2/man pvscan.8.in
Message-ID: <20120226084510.11696.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-26 08:45:07

Modified files:
	man            : pvscan.8.in 

Log message:
	Add tentative documentation of pvscan --lvmetad to the pvscan manpage.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/man/pvscan.8.in	2011/02/04 21:19:04	1.3
+++ LVM2/man/pvscan.8.in	2012/02/26 08:45:07	1.4
@@ -12,6 +12,7 @@
 .RB [ \-n | \-\-novolumegroup ]
 .RB [ \-s | \-\-short ]
 .RB [ \-u | \-\-uuid ]
+.RB [ \-u | \-\-lvmetad ]
 .SH DESCRIPTION
 .B pvscan
 scans all supported LVM block devices in the system for physical volumes.
@@ -29,6 +30,11 @@
 .TP
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
+.TP
+.BR \-u ", " \-\-lvmetad device
+Scan a single device and contact lvmetad to update its cached state. Called
+internally by udev rules. The device is processed \fBregardless\fP of any device
+filters set in lvm.conf.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),


