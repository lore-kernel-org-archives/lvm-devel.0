From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2011 19:32:52 -0000
Subject: LVM2/test t-pvchange-usage.sh
Message-ID: <20110630193252.28630.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-30 19:32:51

Modified files:
	test           : t-pvchange-usage.sh 

Log message:
	update pv_attr check for new missing attr

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-pvchange-usage.sh	2011/01/05 00:16:20	1.6
+++ LVM2/test/t-pvchange-usage.sh	2011/06/30 19:32:51	1.7
@@ -30,9 +30,9 @@
 
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange $dev1 -x n 
-	check pv_field $dev1 pv_attr  --  
+	check pv_field $dev1 pv_attr  ---
 	pvchange $dev1 -x y 
-	check pv_field $dev1 pv_attr  a- 
+	check pv_field $dev1 pv_attr  a--
 
 # 'remove pv'
 	vgremove $vg1 


