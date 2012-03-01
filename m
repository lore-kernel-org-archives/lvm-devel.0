From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:19:21 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20120301211921.11900.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:19:20

Modified files:
	lib/mm         : memlock.c 

Log message:
	Log sys error for lseek

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/mm/memlock.c	2012/02/01 10:48:22	1.50
+++ LVM2/lib/mm/memlock.c	2012/03/01 21:19:20	1.51
@@ -269,7 +269,8 @@
 				return 0;
 			}
 		}
-		lseek(_maps_fd, 0, SEEK_SET);
+		if (lseek(_maps_fd, 0, SEEK_SET))
+			log_sys_error("lseek", _procselfmaps);
 		for (len = 0 ; len < _maps_len; len += n) {
 			if (!(n = read(_maps_fd, _maps_buffer + len, _maps_len - len))) {
 				_maps_buffer[len] = '\0';


