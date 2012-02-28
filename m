From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:17:38 -0000
Subject: LVM2/man pvscan.8.in
Message-ID: <20120228181738.18975.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:17:38

Modified files:
	man            : pvscan.8.in 

Log message:
	spacing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/man/pvscan.8.in	2012/02/28 18:16:23	1.5
+++ LVM2/man/pvscan.8.in	2012/02/28 18:17:37	1.6
@@ -12,7 +12,7 @@
 .RB [ \-n | \-\-novolumegroup ]
 .RB [ \-s | \-\-short ]
 .RB [ \-u | \-\-uuid ]
-.RB [ \-\-lvmetad DevicePath ]
+.RB [ \-\-lvmetad " " DevicePath ]
 .SH DESCRIPTION
 .B pvscan
 scans all supported LVM block devices in the system for physical volumes.
@@ -31,7 +31,7 @@
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
-.BR \-\-lvmetad DevicePath
+.BR \-\-lvmetad " " DevicePath
 Scan a single device and contact lvmetad to update its cached state. Called
 internally by udev rules. The device is processed \fBregardless\fP of any device
 filters set in lvm.conf.


