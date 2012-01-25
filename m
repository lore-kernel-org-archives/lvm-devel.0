From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:36:34 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20120125223634.5482.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:36:33

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Fix leak of hash table
	
	Minor leak on command initialization.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/daemons/clvmd/clvmd.c	2012/01/21 05:31:54	1.117
+++ LVM2/daemons/clvmd/clvmd.c	2012/01/25 22:36:33	1.118
@@ -441,6 +441,7 @@
 
 	/* Setting debug options on an existing clvmd */
 	if (debug_opt && !check_local_clvmd())
+		dm_hash_destroy(lvm_params.excl_uuid);
 		return debug_clvmd(debug_arg, clusterwide_opt)==1?0:1;
 
 	clvmd_set_debug(debug_opt);


