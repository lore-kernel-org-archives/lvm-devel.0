From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 17:45:23 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090727174523.23110.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 17:45:22

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to include lvm_vg_reduce and lvm_vg_extend.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/test/api/test.c	2009/07/26 20:59:02	1.16
+++ LVM2/test/api/test.c	2009/07/27 17:45:21	1.17
@@ -72,6 +72,10 @@
 	       "List the VGs that are currently open\n");
 	printf("'vgs': "
 	       "List all VGs known to the system\n");
+	printf("'vg_extend vgname device: "
+	       "Issue a lvm_vg_extend() API call on VG 'vgname'\n");
+	printf("'vg_reduce vgname device: "
+	       "Issue a lvm_vg_reduce() API call on VG 'vgname'\n");
 	printf("'vg_open vgname ['r' | 'w']': "
 	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
 	printf("'vg_close vgname': "
@@ -172,6 +176,80 @@
 	}
 }
 
+static void _remove_device_from_pvname_hash(struct dm_list *pvs, const char *name)
+{
+	struct lvm_pv_list *pvl;
+	dm_list_iterate_items(pvl, pvs) {
+		if (!strncmp(lvm_pv_get_name(pvl->pv), name, strlen(name)))
+			dm_hash_remove(_pvname_hash, name);
+	}
+}
+static void _add_device_to_pvname_hash(struct dm_list *pvs, const char *name)
+{
+	struct lvm_pv_list *pvl;
+	dm_list_iterate_items(pvl, pvs) {
+		if (!strncmp(lvm_pv_get_name(pvl->pv), name, strlen(name)))
+			dm_hash_insert(_pvname_hash, name, pvl->pv);
+	}
+}
+static void _vg_reduce(char **argv, int argc, lvm_t libh)
+{
+	vg_t *vg;
+	struct dm_list *pvs;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	if (!(vg = dm_hash_lookup(_vgid_hash, argv[1])) &&
+	    !(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("VG not open\n");
+		return;
+	}
+	if (lvm_vg_reduce(vg, argv[2])) {
+		printf("Error reducing %s by %s\n", argv[1], argv[2]);
+		return;
+	}
+
+	printf("Success reducing vg %s by %s\n", argv[1], argv[2]);
+
+	/*
+	 * Add the device into the hashes for lookups
+	 */
+	pvs = lvm_vg_list_pvs(vg);
+	if (pvs && !dm_list_empty(pvs))
+		_remove_device_from_pvname_hash(pvs, argv[2]);
+}
+
+static void _vg_extend(char **argv, int argc, lvm_t libh)
+{
+	vg_t *vg;
+	struct dm_list *pvs;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	if (!(vg = dm_hash_lookup(_vgid_hash, argv[1])) &&
+	    !(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("VG not open\n");
+		return;
+	}
+	if (lvm_vg_extend(vg, argv[2])) {
+		printf("Error extending %s with %s\n", argv[1], argv[2]);
+		return;
+	}
+
+	printf("Success extending vg %s with %s\n", argv[1], argv[2]);
+
+	/*
+	 * Add the device into the hashes for lookups
+	 */
+	pvs = lvm_vg_list_pvs(vg);
+	if (pvs && !dm_list_empty(pvs))
+		_add_device_to_pvname_hash(pvs, argv[2]);
+}
+
 static void _vg_open(char **argv, int argc, lvm_t libh)
 {
 	vg_t *vg;
@@ -443,6 +521,10 @@
 			break;
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
 			_show_help();
+		} else if (!strcmp(argv[0], "vg_extend")) {
+			_vg_extend(argv, argc, libh);
+		} else if (!strcmp(argv[0], "vg_reduce")) {
+			_vg_reduce(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_open")) {
 			_vg_open(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_close")) {


