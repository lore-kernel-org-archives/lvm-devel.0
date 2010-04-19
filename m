From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 19 Apr 2010 14:03:13 -0500
Subject: [PATCH] Prevent simultaneous mirror up-converts (bug 582251)
Message-ID: <1271703793.9666.4.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes bug 582251 by disallowing the addition of
another image to a mirror when it is already in the process
of adding an image.

The fix forces a user to wait for the first conversion to
complete before starting another one.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -996,6 +996,16 @@ static int _lvconvert_mirrors_aux(struct
 		}
 
 		/*
+		 * Is there already a convert in progress?  We do not
+		 * currently allow more than one.
+		 */
+		if (find_temporary_mirror(lv) || (lv->status & CONVERTING)) {
+			log_error("%s is already being converted.  Unable to start another conversion.",
+				  lv->name);
+			return 0;
+		}
+
+		/*
 		 * Log addition/removal should be done before the layer
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
Index: LVM2/test/t-mirror-lvconvert.sh
===================================================================
--- LVM2.orig/test/t-mirror-lvconvert.sh
+++ LVM2/test/t-mirror-lvconvert.sh
@@ -155,11 +155,15 @@ check_and_cleanup_lvs_
 # add 1 mirror
 prepare_lvs_
 lvs -a -o+devices $vg
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
-lvconvert -m+1 -i1 $vg/$lv1 $dev4
+lvconvert -m+1 -b $vg/$lv1 $dev4
+# FIXME:  Next test is a bit time dependent
+#  The test /could/ succeed if the previous conversion
+#  happens quickly enough.
+not lvconvert -m+1 -b $vg/$lv1 $dev5
 lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 3



