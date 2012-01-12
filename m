From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2012 02:32:10 -0000
Subject: LVM2/man lvm.conf.5.in
Message-ID: <20120112023210.13835.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-12 02:32:09

Modified files:
	man            : lvm.conf.5.in 

Log message:
	Add activation/read_only_volume_list to override LV permission in metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/man/lvm.conf.5.in	2011/10/04 20:45:36	1.22
+++ LVM2/man/lvm.conf.5.in	2012/01/12 02:32:09	1.23
@@ -423,6 +423,18 @@
 \fBtags\fP above).
 Logical volume and volume groups can also be included in the list
 by name e.g. vg00, vg00/lvol1.
+.IP
+\fBread_only_volume_list\fP \(em This acts as a filter through
+which all requests to activate a logical volume on this machine
+are passed.  A logical volume is activated in read-only mode (instead
+of read-write) if it matches an item in the list.  Volumes must first
+pass the \fBvolume_list\fP filter, if present.  Tags must be preceded
+by @ and are checked against all tags defined in the logical volume
+and volume group metadata for a match.
+@* is short-hand to check every tag set on the host machine (see
+\fBtags\fP above).
+Logical volume and volume groups can also be included in the list
+by name e.g. vg00, vg00/lvol1.
 .TP
 \fBmetadata\fP \(em Advanced metadata settings
 .IP


