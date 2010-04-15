From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Apr 2010 15:06:29 -0000
Subject: LVM2 ./WHATS_NEW scripts/relpath.awk
Message-ID: <20100415150629.6840.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-15 15:06:27

Modified files:
	.              : WHATS_NEW 
Added files:
	scripts        : relpath.awk 

Log message:
	Added awk script relpath.awk to calculate relative paths.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1525&r2=1.1526
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/relpath.awk.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2010/04/14 21:47:48	1.1525
+++ LVM2/WHATS_NEW	2010/04/15 15:06:26	1.1526
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Added awk script relpath.awk to calculate relative paths.
 
 Version 2.02.63 - 14th April 2010
 =================================
/cvs/lvm2/LVM2/scripts/relpath.awk,v  -->  standard output
revision 1.1
--- LVM2/scripts/relpath.awk
+++ -	2010-04-15 15:06:29.091435000 +0000
@@ -0,0 +1,40 @@
+#!/usr/bin/awk -f
+#
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# relpath.awk: Script is used to calculate relative path
+#	       between two real absolute paths.
+#
+# echo /a/b/c/d  /a/b/e/f | relpath.awk
+# -> ../../e/f/
+
+{
+	split($1, from, "/");
+	split($2, to, "/") ;
+	l = 1;
+	while (l <= length(from) && l <= length(to) && from[l] == to[l])
+		l++;
+	for (i = l; i <= length(from) && length(from[i]); i++) {
+		if (i > l)
+			p = sprintf("%s/", p);
+		p = sprintf("%s..", p);
+	}
+	for (i = l; i <= length(to) && length(to[i]); i++) {
+		if (length(p) > 0)
+			p = sprintf("%s/", p);
+		p = sprintf("%s%s", p, to[i]);
+	}
+	if (length(p))
+		p = sprintf("%s/", p);
+	print p
+}


