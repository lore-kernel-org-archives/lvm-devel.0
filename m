From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Mar 2012 16:59:31 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20120327165931.435.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-27 16:59:29

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Avoid closing clvmd socket twice.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/daemons/clvmd/clvmd.c	2012/03/23 09:43:44	1.132
+++ LVM2/daemons/clvmd/clvmd.c	2012/03/27 16:59:28	1.133
@@ -619,6 +619,8 @@
 	for (newfd = local_client_head.next; newfd != NULL;) {
 		delfd = newfd;
 		newfd = newfd->next;
+		if (delfd->fd == local_sock)
+			delfd->fd = -1;
 		/*
 		 * FIXME:
 		 * needs cleanup code from read_from_local_sock() for now


