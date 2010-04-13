From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Apr 2010 16:13:09 -0000
Subject: LVM2/man lvconvert.8.in
Message-ID: <20100413161309.3007.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-13 16:13:08

Modified files:
	man            : lvconvert.8.in 

Log message:
	Arguments to the --mirrorlog option are described in the synopsis as
	{core|disk|mirrored}.  However, under the options section they are
	described as {core|disk} - even though the 'mirrored' argument is
	described.
	
	s/'{core|disk}'/'{core|disk|mirrored}'/

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/man/lvconvert.8.in	2010/04/13 01:54:33	1.16
+++ LVM2/man/lvconvert.8.in	2010/04/13 16:13:08	1.17
@@ -76,7 +76,7 @@
 volume to a mirror volume with 2-sides; that is, a
 linear volume plus one copy.
 .TP
-.I \-\-mirrorlog {disk|core}
+.I \-\-mirrorlog {disk|core|mirrored}
 Specifies the type of log to use.
 The default is disk, which is persistent and requires
 a small amount of storage space, usually on a separate device


