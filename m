From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Dec 2009 19:32:29 -0000
Subject: LVM2/tools vgchange.c
Message-ID: <20091207193229.28094.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-12-07 19:32:28

Modified files:
	tools          : vgchange.c 

Log message:
	Fix activated/deactivated log_verbose message
	
	I see "Deactivated" message when I activate and "Activated" message when
	I deactivate.  The code uses "activate" as boolean but it can be any one
	of the enum values from CHANGE_AY, CHANGE_AN, CHANGE_AE, etc.
	
	Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
	Acked-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/tools/vgchange.c	2009/11/24 16:08:49	1.91
+++ LVM2/tools/vgchange.c	2009/12/07 19:32:28	1.92
@@ -104,8 +104,8 @@
 
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
-			    activate ? "Activated" : "Deactivated",
-			    count, vg->name);
+			    (activate == CHANGE_AN || activate == CHANGE_ALN)?
+			    "Deactivated" : "Activated", count, vg->name);
 
 	return (expected_count != count) ? ECMD_FAILED : ECMD_PROCESSED;
 }


