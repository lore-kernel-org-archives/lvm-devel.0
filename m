From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 27 May 2010 19:00:21 -0000
Subject: LVM2 ./WHATS_NEW man/dmsetup.8.in
Message-ID: <20100527190021.7752.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-05-27 19:00:20

Modified files:
	.              : WHATS_NEW 
	man            : dmsetup.8.in 

Log message:
	Document 'clear' in dmsetup man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1598&r2=1.1599
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2010/05/24 23:11:34	1.1598
+++ LVM2/WHATS_NEW	2010/05/27 19:00:14	1.1599
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Document 'clear' in dmsetup man page.
   Replace strncmp kernel version number checks with proper ones.
   Avoid selecting names under /dev/block if there is an alternative.
   Update clustered log kernel module name to log-userspace for 2.6.31 onwards.
--- LVM2/man/dmsetup.8.in	2010/03/09 13:42:29	1.34
+++ LVM2/man/dmsetup.8.in	2010/05/27 19:00:20	1.35
@@ -175,6 +175,10 @@
 .br
 Display the library and kernel driver version.
 .SH COMMANDS
+.IP \fBclear
+.I device_name
+.br
+Destroys the table in the inactive table slot for device_name.
 .IP \fBcreate
 .I device_name [-u uuid] [--notable | --table <table> | table_file]
 .br


