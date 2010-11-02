From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Nov 2010 20:10:36 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20101102201036.25035.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-02 20:10:35

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	lost line

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/libdm/regex/parse_rx.c	2010/11/02 19:56:33	1.14
+++ LVM2/libdm/regex/parse_rx.c	2010/11/02 20:10:35	1.15
@@ -574,6 +574,7 @@
 		if (!(r->left = _pass(mem, r->left, changed)))
 			return_NULL;
 
+		break;
 	case OR:
 		/* It's important we optimise sub nodes first */
 		if (!(r->left = _pass(mem, r->left, changed)))


