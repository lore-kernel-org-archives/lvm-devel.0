From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 14:25:14 -0000
Subject: LVM2/libdm/regex matcher.c
Message-ID: <20101129142514.2245.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 14:25:14

Modified files:
	libdm/regex    : matcher.c 

Log message:
	Optimize lookup table read
	
	Reread lookup table only when needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/libdm/regex/matcher.c	2010/11/29 12:43:49	1.14
+++ LVM2/libdm/regex/matcher.c	2010/11/29 14:25:13	1.15
@@ -372,11 +372,11 @@
 {
         struct dfa_state *ns;
 
-        if (!cs->lookup[(unsigned char) c])
-                _calc_state(m, cs, (unsigned char) c);
-
-	if (!(ns = cs->lookup[(unsigned char) c]))
-		return NULL;
+	if (!(ns = cs->lookup[(unsigned char) c])) {
+		_calc_state(m, cs, (unsigned char) c);
+		if (!(ns = cs->lookup[(unsigned char) c]))
+			return NULL;
+	}
 
         // yuck, we have to special case the target trans
         if (ns->final == -1)


