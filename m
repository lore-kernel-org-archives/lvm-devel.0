From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 8 Apr 2008 13:03:14 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20080408130314.30488.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-04-08 13:03:13

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Add config file overrides to clvmd when it reads the LVs list so that
	config items 'command_names' and 'prefix' don't prevent it working.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.830&r2=1.831
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2008/04/08 12:49:20	1.830
+++ LVM2/WHATS_NEW	2008/04/08 13:03:13	1.831
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Addd config file overrides to clvmd when it reads the active LVs list
   Fix vgreduce to use vg_split_mdas to check sufficient mdas remain.
   Add (empty) orphan VGs to lvmcache during initialisation.
   Fix orphan VG name used for format_pool.
--- LVM2/daemons/clvmd/lvm-functions.c	2008/04/04 08:53:47	1.38
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/04/08 13:03:13	1.39
@@ -470,7 +470,7 @@
 	char line[255];
 	FILE *vgs =
 	    popen
-	    ("lvm pvs --nolocking --noheadings -o vg_name", "r");
+	    ("lvm pvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_name", "r");
 
 	sync_unlock("P_orphans", LCK_EXCL);
 
@@ -511,7 +511,7 @@
 	char line[255];
 	FILE *lvs =
 	    popen
-	    ("lvm lvs --nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
+	    ("lvm lvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
 	     "r");
 
 	if (!lvs)


