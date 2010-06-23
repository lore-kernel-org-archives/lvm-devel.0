From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Jun 2010 10:23:00 -0000
Subject: LVM2/tools vgchange.c
Message-ID: <20100623102300.9380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-23 10:22:59

Modified files:
	tools          : vgchange.c 

Log message:
	Fix typo: premitted ->  permitted
	
	Signed-off-by: Takahiro Yasui<tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/tools/vgchange.c	2010/05/24 09:03:39	1.104
+++ LVM2/tools/vgchange.c	2010/06/23 10:22:59	1.105
@@ -627,7 +627,7 @@
 
 	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
 	     arg_count(cmd, sysinit_ARG)) && !arg_count(cmd, available_ARG)) {
-		log_error("Only -a premitted with --ignorelockingfailure and --sysinit");
+		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
 


