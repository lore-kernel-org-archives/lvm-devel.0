From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 22:55:21 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20120301225521.13768.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 22:55:21

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Add traceback for failpath

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/daemons/clvmd/lvm-functions.c	2012/03/01 21:18:38	1.132
+++ LVM2/daemons/clvmd/lvm-functions.c	2012/03/01 22:55:21	1.133
@@ -729,7 +729,7 @@
 	if (dm_asprintf(&lvs_cmd, "%s lvs  --config 'log{command_names=0 prefix=\"\"}' "
 			"--nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
 			lvm_binary) < 0)
-		return 0;
+		return_0;
 
 	/* FIXME: Maybe link and use liblvm2cmd directly instead of fork */
 	if (!(lvs = popen(lvs_cmd, "r"))) {


