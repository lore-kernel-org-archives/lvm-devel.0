From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 18:50:03 -0000
Subject: LVM2/man lvm.conf.5
Message-ID: <20080410185003.17911.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 18:50:02

Modified files:
	man            : lvm.conf.5 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/man/lvm.conf.5	2008/02/04 20:26:14	1.21
+++ LVM2/man/lvm.conf.5	2008/04/10 18:50:02	1.22
@@ -84,7 +84,7 @@
 \fBpreferred_names\fP \(em List of patterns compared in turn against
 all the pathnames referencing the same device in in the scanned directories.
 The pathname that matches the earliest pattern in the list is the
-one used in any output.  As an example, if device mapper multipathing
+one used in any output.  As an example, if device-mapper multipathing
 is used, the following will select multipath device names:
 .br
 \fBdevices { preferred_names = [ "^/dev/mapper/mpath" ] }\fP


