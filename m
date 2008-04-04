From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Apr 2008 11:59:33 -0000
Subject: LVM2 ./WHATS_NEW test/t-pv-range-overflow.sh t ...
Message-ID: <20080404115933.31080.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-04-04 11:59:32

Modified files:
	.              : WHATS_NEW 
	test           : t-pv-range-overflow.sh 
	tools          : pvmove.c 

Log message:
	Add validation of LV name to pvmove -n.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.823&r2=1.824
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2008/04/04 08:53:46	1.823
+++ LVM2/WHATS_NEW	2008/04/04 11:59:29	1.824
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add validation of LV name to pvmove -n.
   Make clvmd refresh the context correctly when lvm.conf is updated.
   Add some basic internal VG lock validation.
   Add per-command flags to control which commands use the VG metadata cache.
--- LVM2/test/t-pv-range-overflow.sh	2007/09/24 19:19:18	1.2
+++ LVM2/test/t-pv-range-overflow.sh	2008/04/04 11:59:30	1.3
@@ -37,14 +37,13 @@
    lvcreate -L4 -n"$lv" "$vg"'
 
 # Test for the bogus diagnostic reported in BZ 284771
-# http://bugzilla.redhat.com/284771.  Once the BZ is fixed,
-# update the code below to expect an improved diagnostic.
+# http://bugzilla.redhat.com/284771.
 test_expect_success \
   'run pvmove with an unrecognized LV name to show bad diagnostic' \
   'pvmove -v -nbogus $d1 $d2 2> err
    test $? = 5 &&
    tail -n1 err > out &&
-   echo "  No data to move for $vg" > expected &&
+   echo "  Logical volume bogus not found." > expected &&
    diff -u out expected'
 
 # With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
--- LVM2/tools/pvmove.c	2008/01/30 14:00:02	1.48
+++ LVM2/tools/pvmove.c	2008/04/04 11:59:31	1.49
@@ -147,6 +147,7 @@
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_list *lvl;
 	uint32_t log_count = 0;
+	int lv_found = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -168,9 +169,13 @@
 	/* Find segments to be moved and set up mirrors */
 	list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
-		if ((lv == lv_mirr) ||
-		    (lv_name && strcmp(lv->name, lv_name)))
+		if ((lv == lv_mirr))
 			continue;
+		if (lv_name) {
+			if (strcmp(lv->name, lv_name))
+				continue;
+			lv_found = 1;
+		}
 		if (lv_is_origin(lv) || lv_is_cow(lv)) {
 			log_print("Skipping snapshot-related LV %s", lv->name);
 			continue;
@@ -196,6 +201,11 @@
 			return_NULL;
 	}
 
+	if (lv_name && !lv_found) {
+		log_error("Logical volume %s not found.", lv_name);
+		return NULL;
+	}
+
 	/* Is temporary mirror empty? */
 	if (!lv_mirr->le_count) {
 		log_error("No data to move for %s", vg->name);
@@ -310,6 +320,11 @@
 			stack;
 			return EINVALID_CMD_LINE;
 		}
+
+		if (!validate_name(lv_name)) {
+			log_error("Logical volume name %s is invalid", lv_name);
+			return EINVALID_CMD_LINE;
+		}
 	}
 
 	/* Read VG */


