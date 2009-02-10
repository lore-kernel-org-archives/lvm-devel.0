From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 10 Feb 2009 13:22:19 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-corosync.c
Message-ID: <20090210132219.26964.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-02-10 13:22:19

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-corosync.c 

Log message:
	Remove duplicate cpg_initialize from clvmd startup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1040&r2=1.1041
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2009/02/10 11:53:33	1.1040
+++ LVM2/WHATS_NEW	2009/02/10 13:22:18	1.1041
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Remove duplicate cpg_initialize from clvmd startup.
   Add option to /etc/sysconfig/cluster to select cluster type for clvmd.
   Allow clvmd to start up if its lockspace already exists.
   Separate PV label attributes which do not need parse metadata when reporting.
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/10 11:52:40	1.3
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/10 13:22:18	1.4
@@ -326,11 +326,6 @@
 	dlm_ls_pthread_init(lockspace);
 	DEBUGLOG("DLM initialisation complete\n");
 
-	err = cpg_initialize(&cpg_handle, &cpg_callbacks);
-	if (err != CS_OK) {
-		return cs_to_errno(err);
-	}
-
 	/* Connect to the clvmd group */
 	strcpy((char *)cpg_group_name.value, "clvmd");
 	cpg_group_name.length = strlen((char *)cpg_group_name.value);


