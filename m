From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Oct 2009 14:55:46 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20091014145546.10036.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-10-14 14:55:45

Modified files:
	lib/metadata   : mirror.c 

Log message:
	I saw this in a bug report:
	[root at xxxx-01 ~]# lvconvert -m 1 --corelog VG/cmirror
	Unable to convert the log of inactive cluster mirror cmirror
	
	I've tried to clean-up the message a little more, so the name
	of the mirror stands out more while preserving the sense that
	it's not a problem with the specific device, but the fact that
	it is inactive that is causing the problem.
	
	New msg:
	Unable to convert the log of an inactive cluster mirror, cmirror

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/lib/metadata/mirror.c	2009/10/01 01:04:27	1.91
+++ LVM2/lib/metadata/mirror.c	2009/10/14 14:55:44	1.92
@@ -1228,8 +1228,8 @@
 			return 0;
 		}
 	} else if (vg_is_clustered(vg)) {
-		log_error("Unable to convert the log of inactive "
-			  "cluster mirror %s", lv->name);
+		log_error("Unable to convert the log of an inactive "
+			  "cluster mirror, %s", lv->name);
 		return 0;
 	} else if (yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "


