From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 10:45:27 -0000
Subject: LVM2/lib/filters filter.c
Message-ID: <20120213104527.4909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 10:45:26

Modified files:
	lib/filters    : filter.c 

Log message:
	Remove duplicit test
	
	When it's space it's also not a '\0'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/lib/filters/filter.c	2012/02/08 12:48:14	1.68
+++ LVM2/lib/filters/filter.c	2012/02/13 10:45:26	1.69
@@ -221,7 +221,7 @@
 
 	while (fgets(line, 80, pd) != NULL) {
 		i = 0;
-		while (line[i] == ' ' && line[i] != '\0')
+		while (line[i] == ' ')
 			i++;
 
 		/* If it's not a number it may be name of section */
@@ -238,7 +238,7 @@
 		/* Find the start of the device major name */
 		while (line[i] != ' ' && line[i] != '\0')
 			i++;
-		while (line[i] == ' ' && line[i] != '\0')
+		while (line[i] == ' ')
 			i++;
 
 		/* Look for md device */


