From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:25:24 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20120215122524.22373.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:25:24

Modified files:
	man            : dmsetup.8.in 

Log message:
	Add dmsetup manpage entries for mangle command and --manglename option.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/man/dmsetup.8.in	2012/01/18 18:52:02	1.50
+++ LVM2/man/dmsetup.8.in	2012/02/15 12:25:23	1.51
@@ -64,6 +64,9 @@
 .B dmsetup mknodes
 .RI [ device_name ]
 .br
+.B dmsetup mangle
+.RI [ device_name ]
+.br
 .B dmsetup reload
 .I device_name
 .RB [ \-\-table
@@ -186,6 +189,17 @@
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
 .TP
+.IR \fB\-\-manglename \ < mangling_mode >
+Mangle any character not on a whitelist using mangling_mode when
+processing device-mapper device names. The names are mangled on
+input and unmangled on output where the mangling_mode is one of:
+none (no mangling), hex (always do the mangling) and auto
+(only do the mangling if not mangled yet, do nothing if already
+mangled, error on mixed; this is used by default).
+Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
+also supported by udev. Any character not on a whitelist is replaced
+with its hex value (two digits) prefixed by \\x.
+.TP
 .BR \-j | \-\-major\ \fImajor
 Specify the major number.
 .TP
@@ -382,6 +396,15 @@
 driver, adding, changing or removing nodes as necessary.
 .br
 .HP
+.B mangle
+.RI [ device_name ]
+.br
+Ensure existing device-mapper device name is in the correct mangled
+form containing only whitelisted characters (supported by udev) and do
+a rename if necessary. Any character not on the whitelist will be mangled
+based on the --manglename settting.
+.br
+.HP
 .B remove
 .RB [ \-f | \-\-force ]
 .RB [ \-\-retry ]


