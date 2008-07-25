From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Jul 2008 14:59:52 -0000
Subject: LVM2 test/t-pvcreate-operation.sh tools/pvcreate.c
Message-ID: <20080725145952.3552.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-25 14:59:51

Modified files:
	test           : t-pvcreate-operation.sh 
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - simplify return codes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/test/t-pvcreate-operation.sh	2008/07/25 14:36:52	1.5
+++ LVM2/test/t-pvcreate-operation.sh	2008/07/25 14:59:51	1.6
@@ -42,6 +42,18 @@
    vgremove -f $vg1 &&
    pvremove -f $d1'
 
+test_expect_success \
+  "pvcreate (lvm$mdatype) fails when PV1 does and PV2 does not belong to VG" \
+  'pvcreate -M$mdatype $d1 &&
+   pvcreate -M$mdatype $d2 &&
+   vgcreate -M$mdatype $vg1 $d1 &&
+   echo pvcreate a second time on $d2 and $d1 &&
+   pvcreate -M$mdatype $d2 $d1;
+   status=$?; echo status=$status; test $status != 0 &&
+   vgremove -f $vg1 &&
+   pvremove -f $d2 &&
+   pvremove -f $d1'
+
 done
 
 test_expect_success \
--- LVM2/tools/pvcreate.c	2008/07/25 14:45:24	1.72
+++ LVM2/tools/pvcreate.c	2008/07/25 14:59:51	1.73
@@ -153,13 +153,13 @@
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			log_error("uuid %s already in use on \"%s\"",
 				  pp->idp->uuid, dev_name(dev));
-			return ECMD_FAILED;
+			return 0;
 		}
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!pvcreate_check(cmd, pv_name, pp))
@@ -218,11 +218,11 @@
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
 	unlock_vg(cmd, VG_ORPHANS);
-	return ECMD_PROCESSED;
+	return 1;
 
       error:
 	unlock_vg(cmd, VG_ORPHANS);
-	return ECMD_FAILED;
+	return 0;
 }
 
 /*
@@ -352,7 +352,7 @@
 
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
-	int i, r;
+	int i;
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
 
@@ -361,9 +361,9 @@
 	}
 
 	for (i = 0; i < argc; i++) {
-		r = pvcreate_single(cmd, argv[i], &pp);
-		if (r > ret)
-			ret = r;
+		if (!pvcreate_single(cmd, argv[i], &pp))
+			ret = ECMD_FAILED;
+
 		if (sigint_caught())
 			return ret;
 	}


