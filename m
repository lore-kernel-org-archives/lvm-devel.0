From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jan 2008 16:47:11 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20080108164711.6438.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-01-08 16:47:10

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	readahead at least twice the strip size (same as raid0 driver does)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/lib/activate/dev_manager.c	2007/12/05 19:24:31	1.131
+++ LVM2/lib/activate/dev_manager.c	2008/01/08 16:47:10	1.132
@@ -953,7 +953,8 @@
 	}
 
 	if (read_ahead == DM_READ_AHEAD_AUTO) {
-		read_ahead = max_stripe_size;
+		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
+		read_ahead = max_stripe_size * 2;
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 	}
 


