From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 15:03:28 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20110113150328.18360.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 15:03:28

Modified files:
	test/lib       : harness.c 

Log message:
	Set default value to counter_last
	
	Missed in previous commit and could be using some random stack value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/lib/harness.c	2011/01/13 11:02:55	1.4
+++ LVM2/test/lib/harness.c	2011/01/13 15:03:28	1.5
@@ -110,7 +110,7 @@
 }
 
 static void dump(void) {
-	int counter_last, counter = 0;
+	int counter_last = -1, counter = 0;
 
 	while ( counter < readbuf_used && counter != counter_last ) {
 		counter_last = counter;


