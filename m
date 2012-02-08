From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 12:59:45 -0000
Subject: LVM2/libdm libdm-file.c
Message-ID: <20120208125945.28790.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 12:59:45

Modified files:
	libdm          : libdm-file.c 

Log message:
	Drop unreachable code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/libdm/libdm-file.c	2011/09/22 17:23:36	1.17
+++ LVM2/libdm/libdm-file.c	2012/02/08 12:59:45	1.18
@@ -135,7 +135,6 @@
 		switch (errno) {
 		case EINTR:
 			goto retry_fcntl;
-			break;
 		case EACCES:
 		case EAGAIN:
 			if (retries == 20) {


