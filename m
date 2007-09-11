From: meyering@sourceware.org <meyering@sourceware.org>
Date: 11 Sep 2007 20:12:54 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20070911201254.13001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-11 20:12:54

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Diagnose invalid PE values given on the pvmove command line (64-bit systems).
	
	* tools/toollib.c (xstrtouint32): New function.
	(_parse_pes): Use xstrtouint32; don't cast strtoul's unsigned
	long to uint32_t.  Detect overflow.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.704&r2=1.705
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/WHATS_NEW	2007/09/11 13:49:51	1.704
+++ LVM2/WHATS_NEW	2007/09/11 20:12:54	1.705
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Diagnose invalid PE values given on the pvmove command line (64-bit systems).
   Include strerror string in dev_open_flags' stat failure message.
   Move guts of pvresize into library.
   Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
--- LVM2/tools/toollib.c	2007/08/22 14:38:18	1.105
+++ LVM2/tools/toollib.c	2007/09/11 20:12:54	1.106
@@ -911,6 +911,18 @@
 	return 1;
 }
 
+static int xstrtouint32(const char *s, char **p, int base, uint32_t *result)
+{
+	unsigned long ul;
+
+	errno = 0;
+	ul = strtoul(s, p, base);
+	if (errno || *p == s || (uint32_t) ul != ul)
+		return -1;
+	*result = ul;
+	return 0;
+}
+
 static int _parse_pes(struct dm_pool *mem, char *c, struct list *pe_ranges,
 		      const char *pvname, uint32_t size)
 {
@@ -942,8 +954,7 @@
 
 		/* Start extent given? */
 		if (isdigit(*c)) {
-			start = (uint32_t) strtoul(c, &endptr, 10);
-			if (endptr == c)
+			if (xstrtouint32(c, &endptr, 10, &start))
 				goto error;
 			c = endptr;
 			/* Just one number given? */
@@ -954,8 +965,7 @@
 		if (*c == '-') {
 			c++;
 			if (isdigit(*c)) {
-				end = (uint32_t) strtoul(c, &endptr, 10);
-				if (endptr == c)
+				if (xstrtouint32(c, &endptr, 10, &end))
 					goto error;
 				c = endptr;
 			}


