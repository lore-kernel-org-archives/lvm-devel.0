From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:36:11 -0000
Subject: LVM2/lib/filters filter.c
Message-ID: <20111118193611.24165.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:36:10

Modified files:
	lib/filters    : filter.c 

Log message:
	Remove constant expression check
	
	"result_independent_of_operands: ((dev->dev & 0xfff00UL) >> 8) ==
	18446744073709551615UL /* -1 */ is always false regardless of the values
	of its operands (logical operand of if)."
	
	'dev->dev' is set in dev-cache.c _insert() and it's not expectable
	st_rdev would have '-1'
	
	This code has been introduced with drbd support commit and code never
	worked - so eliminated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/lib/filters/filter.c	2011/11/11 16:59:30	1.65
+++ LVM2/lib/filters/filter.c	2011/11/18 19:36:10	1.66
@@ -64,9 +64,6 @@
 {
 	dev_t primary_dev;
 
-	if (MAJOR(dev->dev) == -1)
-		return 0;
-
 	if (MAJOR(dev->dev) == _md_major)
 		return 1;
 


