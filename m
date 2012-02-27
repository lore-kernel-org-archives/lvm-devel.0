From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:19:00 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120227101900.19358.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:19:00

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Add assert for oldname
	
	Code cannot proceed if oldname would be NULL.
	Since lvmetad currently doesn't use logging mechanism of lvm to report
	internal errors - stay with current code style of lvmetad which uses
	plain asserts for cases like this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/27 10:10:43	1.43
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/27 10:19:00	1.44
@@ -595,6 +595,7 @@
 
 	if (!old)
 		return 0;
+	assert(oldname);
 
 	if (update_pvids)
 		update_pvid_to_vgid(s, old, "#orphan", 0);


