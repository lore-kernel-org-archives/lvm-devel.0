From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 09:48:12 -0000
Subject: LVM2/test harness.c
Message-ID: <20100407094812.31796.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 09:48:11

Modified files:
	test           : harness.c 

Log message:
	In test harness, use fwrite(3) in place of write(2) to avoid mixing fd-level
	and FILE-level IO on stdout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/harness.c	2010/04/07 09:41:33	1.7
+++ LVM2/test/harness.c	2010/04/07 09:48:11	1.8
@@ -37,7 +37,7 @@
 }
 
 void dump() {
-	write(1, readbuf, readbuf_used);
+	fwrite(readbuf, 1, readbuf_used, stdout);
 }
 
 void clear() {


