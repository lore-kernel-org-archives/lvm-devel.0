From: thornber@sourceware.org <thornber@sourceware.org>
Date: 9 Aug 2010 10:30:52 -0000
Subject: LVM2/libdm/regex matcher.c
Message-ID: <20100809103052.19842.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-08-09 10:30:52

Modified files:
	libdm/regex    : matcher.c 

Log message:
	[REGEX] fix bug in matcher that was causing segfault with chars of 0x80 and over.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/libdm/regex/matcher.c	2010/07/21 12:09:13	1.11
+++ LVM2/libdm/regex/matcher.c	2010/08/09 10:30:52	1.12
@@ -375,7 +375,7 @@
         struct dfa_state *ns;
 
         if (!(ns = cs->lookup[(unsigned char) c]))
-                _calc_state(m, cs, c);
+                _calc_state(m, cs, (unsigned char) c);
 
 	if (!(ns = cs->lookup[(unsigned char) c]))
 		return NULL;


