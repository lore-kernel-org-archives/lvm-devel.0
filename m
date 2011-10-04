From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Oct 2011 20:45:36 -0000
Subject: LVM2/man lvm.conf.5.in
Message-ID: <20111004204536.13709.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-10-04 20:45:36

Modified files:
	man            : lvm.conf.5.in 

Log message:
	Clarify multi-name device filter pattern matching explanation in lvm.conf.5.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/man/lvm.conf.5.in	2011/04/29 00:21:16	1.21
+++ LVM2/man/lvm.conf.5.in	2011/10/04 20:45:36	1.22
@@ -97,10 +97,10 @@
 any patterns are accepted. If you want to reject patterns that
 don't match, end the list with "r/.*/".
 If there are several names for the same device (e.g. symbolic links
-in /dev), if any name matches any \fBa\fP pattern, the
-device is accepted; otherwise if any name matches any \fBr\fP
-pattern it is rejected; otherwise it is accepted.
-As an example, to ignore /dev/cdrom you could use:
+in /dev), if the first matching pattern in the list for any of the names is an
+\fBa\fP pattern, the device is accepted; otherwise if the first matching
+pattern in the list for any of the names is an \fBr\fP pattern it is rejected;
+otherwise it is accepted.  As an example, to ignore /dev/cdrom you could use:
 .br
 \fBdevices { filter=["r|cdrom|"] }\fP 
 .IP


