From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Oct 2009 13:12:20 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20091022131220.3689.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-22 13:12:20

Modified files:
	man            : dmsetup.8.in 

Log message:
	Add manpage entry for dmsetup udevflags.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/man/dmsetup.8.in	2009/09/23 12:52:52	1.26
+++ LVM2/man/dmsetup.8.in	2009/10/22 13:12:20	1.27
@@ -64,6 +64,9 @@
 .B dmsetup mknodes
 .I [device_name]
 .br
+.B dmsetup udevflags
+.I cookie
+.br
 .B dmsetup udevcomplete
 .I cookie
 .br
@@ -303,6 +306,18 @@
 .IP \fBtargets
 .br
 Displays the names and versions of the currently-loaded targets.
+.br
+.IP \fBudevflags
+.I cookie
+.br
+Parses given cookie value and extracts any udev control flags encoded.
+The output is in environment key format that is suitable for use in udev
+rules. If the flag has its symbolic name assigned then the ouput is
+DM_UDEV_FLAG_<flag_name>='1', DM_UDEV_FLAG<flag_position>='1' otherwise.
+Subsystem udev flags don't have symbolic names assigned and these ones are
+always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
+16 udev flags altogether.
+.br
 .IP \fBudevcomplete
 .I cookie
 .br


