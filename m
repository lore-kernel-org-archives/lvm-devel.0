From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Jun 2010 08:18:55 -0000
Subject: LVM2/man lvmdump.8.in
Message-ID: <20100624081855.30418.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-24 08:18:54

Modified files:
	man            : lvmdump.8.in 

Log message:
	Add few missing information about what is this script doing.
	(based upon Debian bugzilla suggestion)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdump.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/man/lvmdump.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvmdump.8.in	2010/06/24 08:18:54	1.2
@@ -14,10 +14,14 @@
 .br
 - recent entries from /var/log/messages (containing system messages)
 .br
-- complete lvm configuration and cache
+- complete lvm configuration and cache (content of /etc/lvm)
 .br
 - list of device nodes present under /dev
 .br
+- list of files present /sys/block
+.br
+- list of files present /sys/devices/virtual/block
+.br
 - if enabled with -m, metadata dump will be also included
 .br
 - if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included


