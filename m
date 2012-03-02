From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 02:55:46 -0000
Subject: LVM2/tools pvremove.c
Message-ID: <20120302025546.4520.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 02:55:45

Modified files:
	tools          : pvremove.c 

Log message:
	Reinstate error if e.g. daemon comms fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/tools/pvremove.c	2012/03/01 21:46:31	1.39
+++ LVM2/tools/pvremove.c	2012/03/02 02:55:45	1.40
@@ -128,8 +128,9 @@
 		goto out;
 	}
 
+	/* FIXME Avoid error if we expect that daemon might not know device */
 	if (!lvmetad_pv_gone(dev->dev))
-		log_debug("PV gone"); /* FIXME any better idea */
+		goto_out;
 
 	log_print("Labels on physical volume \"%s\" successfully wiped",
 		  pv_name);


