From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Mar 2011 13:11:46 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20110310131146.20558.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-10 13:11:45

Modified files:
	man            : dmsetup.8.in 

Log message:
	Fix dmsetup man page typo (John Bradshaw)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/man/dmsetup.8.in	2011/02/04 19:33:54	1.37
+++ LVM2/man/dmsetup.8.in	2011/03/10 13:11:45	1.38
@@ -290,7 +290,7 @@
 be removed because uninterruptible processes are waiting for
 I/O to return from them, adding --force will replace the table 
 with one that fails all I/O, which might allow the 
-process to be killed.  This also runs \fBmknodes\fP afterwards.
+process to be killed.  This also runs \fBmknodes\fP afterward.
 .IP \fBrename
 .I device_name new_name
 .br
@@ -374,7 +374,7 @@
 .br
 Parses given cookie value and extracts any udev control flags encoded.
 The output is in environment key format that is suitable for use in udev
-rules. If the flag has its symbolic name assigned then the ouput is
+rules. If the flag has its symbolic name assigned then the output is
 DM_UDEV_FLAG_<flag_name>='1', DM_UDEV_FLAG<flag_position>='1' otherwise.
 Subsystem udev flags don't have symbolic names assigned and these ones are
 always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are


