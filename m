From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:41:27 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110925194127.17721.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:41:27

Modified files:
	libdm          : libdm-config.c 

Log message:
	Replace test for NULL of root->child with test for NULL l
	
	It's 100% equivalent test - since it always happen for the first iteration.
	But the check for 'l' is understandable with analyzers - since analyzer
	is not smart enough to deduce connection between  root->child == NULL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/libdm/libdm-config.c	2011/09/25 19:40:29	1.9
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:41:27	1.10
@@ -557,7 +557,7 @@
 			if (!(n = _section(p)))
 				return_NULL;
 
-			if (!root->child)
+			if (!l)
 				root->child = n;
 			else
 				l->sib = n;


