From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 12:17:20 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20110105121720.29669.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 12:17:20

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Remove dead assignment to thisfd
	
	Value of 'thisfd' is not read again after its assigment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/daemons/clvmd/clvmd.c	2010/12/22 14:00:28	1.91
+++ LVM2/daemons/clvmd/clvmd.c	2011/01/05 12:17:19	1.92
@@ -830,7 +830,6 @@
 					struct local_client *free_fd;
 					lastfd->next = thisfd->next;
 					free_fd = thisfd;
-					thisfd = lastfd;
 
 					DEBUGLOG("removeme set for fd %d\n", free_fd->fd);
 
@@ -866,7 +865,6 @@
 							 ret, errno);
 						lastfd->next = thisfd->next;
 						free_fd = thisfd;
-						thisfd = lastfd;
 						safe_close(&(free_fd->fd));
 
 						/* Queue cleanup, this also frees the client struct */


