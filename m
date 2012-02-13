From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Feb 2012 18:38:37 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120213183837.1938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-13 18:38:37

Modified files:
	tools          : lvconvert.c 

Log message:
	Change confusing message that is printed when a RAID device fails.
	
	s/Issue/Use/, otherwise it is easy to misread "Issue" as "Issuing" - causing
	the user confusion as to whether the action was performed automatically or
	whether they need to issue the command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182

--- LVM2/tools/lvconvert.c	2012/02/13 18:36:55	1.181
+++ LVM2/tools/lvconvert.c	2012/02/13 18:38:36	1.182
@@ -1537,7 +1537,7 @@
 
 		/* "warn" if policy not set to replace */
 		if (arg_count(cmd, use_policies_ARG))
-			log_error("Issue 'lvconvert --repair %s/%s' to "
+			log_error("Use 'lvconvert --repair %s/%s' to "
 				  "replace failed device",
 				  lv->vg->name, lv->name);
 		return 1;


