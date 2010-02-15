From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 16:32:24 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20100215163224.1391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 16:32:24

Modified files:
	man            : dmsetup.8.in 

Log message:
	Update man page for dmsetup: --udevcookie, udevcreatecookie and udevreleasecookie.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/man/dmsetup.8.in	2010/01/07 19:45:12	1.30
+++ LVM2/man/dmsetup.8.in	2010/02/15 16:32:24	1.31
@@ -64,6 +64,11 @@
 .B dmsetup mknodes
 .I [device_name]
 .br
+.B dmsetup udevcreatecookie
+.br
+.B dmsetup udevreleasecookie
+.I [cookie]
+.br
 .B dmsetup udevflags
 .I cookie
 .br
@@ -127,6 +132,9 @@
 .IP \fB--notable
 .br
 When creating a device, don't load any table.
+.IP \fB--udevcookie\ \fIcookie
+.br
+Use cookie for udev synchronisation.
 .IP \fB--noudevrules
 Do not allow udev to manage nodes for devices in device-mapper directory.
 .br
@@ -315,6 +323,26 @@
 .br
 Displays the names and versions of the currently-loaded targets.
 .br
+.IP \fBudevcreatecookie
+.br
+Creates a new cookie to synchronize actions with udev processing.
+The output is a cookie value. Normally we don't need to create cookies since
+dmsetup creates and destroys them for each action automatically. However, we can
+generate one explicitly to group several actions together and use only one
+cookie instead. We can define a cookie to use for each relevant command by using
+--udevcookie option. Alternatively, we can export this value into the environment
+of the dmsetup process as DM_UDEV_COOKIE variable and it will be used automatically
+with all subsequent commands until it is unset.
+Invoking this command will create system-wide semaphore that needs to be cleaned
+up explicitly by calling udevreleasecookie command.
+.br
+.IP \fBudevreleasecookie
+.I [cookie]
+.br
+Waits for all pending udev processing bound to given cookie value and clean up
+the cookie with underlying semaphore. If the cookie is not given directly,
+the command will try to use a value defined by DM_UDEV_COOKIE environment variable.
+.br
 .IP \fBudevflags
 .I cookie
 .br
@@ -412,6 +440,10 @@
 \fBDM_DEV_DIR\fP
 The device directory name.
 Defaults to "/dev" and must be an absolute path.
+.TP
+\fBDM_UDEV_COOKIE\fP
+A cookie to use for all relevant commands to synchronize with udev processing.
+It is an alternative to using --udevcookie option.
 
 .SH AUTHORS
 Original version: Joe Thornber (thornber at sistina.com)


