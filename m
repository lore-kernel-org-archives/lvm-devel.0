From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 12:43:50 -0000
Subject: LVM2/libdm/regex matcher.c
Message-ID: <20101129124350.26591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 12:43:49

Modified files:
	libdm/regex    : matcher.c 

Log message:
	Remove dead assignment in _step_matcher
	
	'ns' is not used after this assignment and it is reassigned with the following
	code, so dropping this assignment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/libdm/regex/matcher.c	2010/09/30 21:06:52	1.13
+++ LVM2/libdm/regex/matcher.c	2010/11/29 12:43:49	1.14
@@ -372,7 +372,7 @@
 {
         struct dfa_state *ns;
 
-        if (!(ns = cs->lookup[(unsigned char) c]))
+        if (!cs->lookup[(unsigned char) c])
                 _calc_state(m, cs, (unsigned char) c);
 
 	if (!(ns = cs->lookup[(unsigned char) c]))


