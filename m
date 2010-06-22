From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Jun 2010 07:34:35 -0000
Subject: LVM2/man dmeventd.8.in
Message-ID: <20100622073435.14295.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-22 07:34:34

Modified files:
	man            : dmeventd.8.in 

Log message:
	Adding section number for lvm.conf manpages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmeventd.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/dmeventd.8.in	2010/06/21 15:56:59	1.2
+++ LVM2/man/dmeventd.8.in	2010/06/22 07:34:34	1.3
@@ -16,13 +16,13 @@
 LVM PLUGINS
 .TP
 .I Mirror
-Attempts to handle device failure automatically.  See \fBlvm.conf\fP).
+Attempts to handle device failure automatically.  See \fBlvm.conf\fP(5).
 .TP
 .I Snapshot
 Monitors how full a snapshot is becoming and emits a warning to
 syslog when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
-See \fBlvm.conf\fP.
+See \fBlvm.conf\fP(5).
 .SH OPTIONS
 .TP
 .I \-d


