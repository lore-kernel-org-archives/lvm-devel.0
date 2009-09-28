From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Sep 2009 16:36:04 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c
Message-ID: <20090928163604.28408.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-28 16:36:03

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 

Log message:
	Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
	
	's' and 'S' are special suffixes representing sectors and are always 512 bytes,
	regardless of whether you're using powers of 1000 or 1024.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1274&r2=1.1275
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/WHATS_NEW	2009/09/28 16:23:44	1.1274
+++ LVM2/WHATS_NEW	2009/09/28 16:36:03	1.1275
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
   Use standard output units for 'PE Size' and 'Stripe size' in pv/lvdisplay.
   Add configure --enable-units-compat to set si_unit_consistency off by default.
   Add global/si_unit_consistency to enable cleaned-up use of units in output.
--- LVM2/lib/display/display.c	2009/09/28 16:23:46	1.102
+++ LVM2/lib/display/display.c	2009/09/28 16:36:03	1.103
@@ -68,6 +68,7 @@
 		break;
 #define KILO UINT64_C(1024)
 	case 's':
+	case 'S':
 		v *= (KILO/2);
 		break;
 	case 'k':
@@ -90,9 +91,6 @@
 		break;
 #undef KILO
 #define KILO UINT64_C(1000)
-	case 'S':
-		v *= (KILO/2);
-		break;
 	case 'K':
 		v *= KILO;
 		break;


