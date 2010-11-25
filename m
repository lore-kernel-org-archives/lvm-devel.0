From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Nov 2010 14:35:48 -0000
Subject: LVM2/test/api test.c
Message-ID: <20101125143548.12407.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-25 14:35:47

Modified files:
	test/api       : test.c 

Log message:
	Add interactive tests for functions to lookup a pv|lv by name|uuid.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/test/api/test.c	2010/11/17 20:13:51	1.33
+++ LVM2/test/api/test.c	2010/11/25 14:35:46	1.34
@@ -113,6 +113,14 @@
 	       "Lookup a vgname from a device name\n");
 	printf("'vgname_from_pvid pvid': "
 	       "Lookup a vgname from a pvid\n");
+	printf("'lv_from_uuid vgname lvuuid': "
+	       "Lookup an LV from an LV uuid\n");
+	printf("'lv_from_name vgname lvname': "
+	       "Lookup an LV from an LV name\n");
+	printf("'pv_from_uuid vgname pvuuid': "
+	       "Lookup an LV from an LV uuid\n");
+	printf("'pv_from_name vgname pvname': "
+	       "Lookup an LV from an LV name\n");
 	printf("'quit': exit the program\n");
 }
 
@@ -468,6 +476,30 @@
 		lvm_vg_get_pv_count(vg), lvm_vg_get_seqno(vg));
 }
 
+static void _print_pv(pv_t pv)
+{
+	if (!pv)
+		return;
+	printf("%s (%s): size=%"PRIu64", free=%"PRIu64
+	       ", dev_size=%"PRIu64", mda_count=%"PRIu64"\n",
+	       lvm_pv_get_name(pv), lvm_pv_get_uuid(pv),
+	       lvm_pv_get_size(pv), lvm_pv_get_free(pv),
+	       lvm_pv_get_dev_size(pv),
+	       lvm_pv_get_mda_count(pv));
+}
+
+static void _print_lv(vg_t vg, lv_t lv)
+{
+	if (!lv)
+		return;
+	printf("%s/%s (%s): size=%"PRIu64", %sACTIVE / %sSUSPENDED\n",
+	       lvm_vg_get_name(vg),
+	       lvm_lv_get_name(lv), lvm_lv_get_uuid(lv),
+	       lvm_lv_get_size(lv),
+	       lvm_lv_is_active(lv) ? "" : "IN",
+	       lvm_lv_is_suspended(lv) ? "" : "NOT ");
+}
+
 static void _list_open_vgs(void)
 {
 	dm_hash_iter(_vgid_hash, (dm_hash_iterate_fn) _show_one_vg);
@@ -488,12 +520,7 @@
 	}
 	printf("PVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(pvl, pvs) {
-		printf("%s (%s): size=%"PRIu64", free=%"PRIu64
-			", dev_size=%"PRIu64", mda_count=%"PRIu64"\n",
-			lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv),
-			lvm_pv_get_size(pvl->pv), lvm_pv_get_free(pvl->pv),
-			lvm_pv_get_dev_size(pvl->pv),
-			lvm_pv_get_mda_count(pvl->pv));
+		_print_pv(pvl->pv);
 	}
 }
 
@@ -715,6 +742,59 @@
 	printf("%s tag %s to LV %s\n",
 	       add ? "adding":"removing", argv[3], argv[2]);
 }
+
+static void _lv_from_uuid(char **argv, int argc)
+{
+	vg_t vg;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lv_uuid\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	_print_lv(vg, lvm_lv_from_uuid(vg, argv[2]));
+}
+
+static void _lv_from_name(char **argv, int argc)
+{
+	vg_t vg;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lv_uuid\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	_print_lv(vg, lvm_lv_from_name(vg, argv[2]));
+}
+
+static void _pv_from_uuid(char **argv, int argc)
+{
+	vg_t vg;
+
+	if (argc < 3) {
+		printf("Please enter vgname, pv_uuid\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	_print_pv(lvm_pv_from_uuid(vg, argv[2]));
+}
+
+static void _pv_from_name(char **argv, int argc)
+{
+	vg_t vg;
+
+	if (argc < 3) {
+		printf("Please enter vgname, pv_uuid\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	_print_pv(lvm_pv_from_name(vg, argv[2]));
+}
+
 static void _vgname_from_pvid(char **argv, int argc, lvm_t libh)
 {
 	const char *vgname;
@@ -762,12 +842,7 @@
 	}
 	printf("LVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(lvl, lvs) {
-		printf("%s/%s (%s): size=%"PRIu64", %sACTIVE / %sSUSPENDED\n",
-			lvm_vg_get_name(vg),
-			lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv),
-			lvm_lv_get_size(lvl->lv),
-			lvm_lv_is_active(lvl->lv) ? "" : "IN",
-			lvm_lv_is_suspended(lvl->lv) ? "" : "NOT ");
+		_print_lv(vg, lvl->lv);
 	}
 }
 
@@ -978,6 +1053,14 @@
 			_vgname_from_devname(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vgname_from_pvid")) {
 			_vgname_from_pvid(argv, argc, libh);
+		} else if (!strcmp(argv[0], "lv_from_uuid")) {
+			_lv_from_uuid(argv, argc);
+		} else if (!strcmp(argv[0], "lv_from_name")) {
+			_lv_from_name(argv, argc);
+		} else if (!strcmp(argv[0], "pv_from_uuid")) {
+			_pv_from_uuid(argv, argc);
+		} else if (!strcmp(argv[0], "pv_from_name")) {
+			_pv_from_name(argv, argc);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}


