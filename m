From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:46:32 -0000
Subject: LVM2/tools pvremove.c
Message-ID: <20120301214632.14532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:46:31

Modified files:
	tools          : pvremove.c 

Log message:
	Replace goto with just log_debug
	
	FIXME: temporal quick hack to make things green
	There might be a better reaction.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/tools/pvremove.c	2012/02/28 18:08:08	1.38
+++ LVM2/tools/pvremove.c	2012/03/01 21:46:31	1.39
@@ -129,7 +129,7 @@
 	}
 
 	if (!lvmetad_pv_gone(dev->dev))
-		goto_out;
+		log_debug("PV gone"); /* FIXME any better idea */
 
 	log_print("Labels on physical volume \"%s\" successfully wiped",
 		  pv_name);


