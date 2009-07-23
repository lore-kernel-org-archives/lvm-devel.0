From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 23:40:50 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090723234050.21408.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 23:40:50

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c for simple tests involving pv/vg/lv name/uuid attributes.
	
	Tests the following APIs:
	- lvm_{pv|vg|lv}_get_{name|uuid}()
	- lvm_{lvs|pvs}_in_vg()
	
	Example:
	lvm> vg_open VolGroup00
	Success opening vg VolGroup00
	lvm> vg_list_lvs VolGroup00
	LVs in VG VolGroup00:
	VolGroup00/LogVol00 (bFO4EU-UaDu-iuMm-N6BA-xcZc-nm3u-J5K5lu)
	VolGroup00/LogVol01 (BHGsPK-PwzY-kye0-MEWa-a67z-BiYE-03ZjwM)
	lvm> vg_list_pvs VolGroup00
	PVs in VG VolGroup00:
	/dev/sda2 (Be91pt-CqT0-4YJE-nGI6-Oisz-hy0N-l9CHgn)
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Thomas Woerner <twoerner@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/api/test.c	2009/02/24 13:03:45	1.2
+++ LVM2/test/api/test.c	2009/07/23 23:40:50	1.3
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -29,7 +29,7 @@
 		while (*b && isspace(*b))
 			b++;
 
-		if ((!*b) || (*b == '#'))
+		if ((!*b) || ((*argc == 0)&&(*b == '#')))
 			break;
 
 		e = b;
@@ -48,11 +48,204 @@
 	return *argc;
 }
 
+static void _show_help(void)
+{
+	printf("'vg_list_pvs vgname': "
+	       "List the PVs that exist in VG vgname\n");
+	printf("'vg_list_lvs vgname': "
+	       "List the LVs that exist in VG vgname\n");
+	printf("'vgs_open': "
+	       "List the VGs that are currently open\n");
+	printf("'vgs': "
+	       "List all VGs known to the system\n");
+	printf("'vg_open vgname ['r' | 'w']': "
+	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
+	printf("'vg_close vgname': "
+	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'quit': exit the program\n");
+}
+
+static struct dm_hash_table *_vgid_hash = NULL;
+static struct dm_hash_table *_vgname_hash = NULL;
+static struct dm_hash_table *_pvname_hash = NULL;
+static struct dm_hash_table *_lvname_hash = NULL;
+
+static void _hash_destroy_single(struct dm_hash_table **htable)
+{
+	if (htable && *htable) {
+		dm_hash_destroy(*htable);
+		*htable = NULL;
+	}
+}
+
+static void _hash_destroy(void)
+{
+	_hash_destroy_single(&_vgname_hash);
+	_hash_destroy_single(&_vgid_hash);
+	_hash_destroy_single(&_pvname_hash);
+	_hash_destroy_single(&_lvname_hash);
+}
+
+static int _hash_create(void)
+{
+	if (!(_vgname_hash = dm_hash_create(128)))
+		return 0;
+	if (!(_pvname_hash = dm_hash_create(128))) {
+		_hash_destroy_single(&_vgname_hash);
+		return 0;
+	}
+	if (!(_lvname_hash = dm_hash_create(128))) {
+		_hash_destroy_single(&_vgname_hash);
+		_hash_destroy_single(&_pvname_hash);
+		return 0;
+	}
+	if (!(_vgid_hash = dm_hash_create(128))) {
+		_hash_destroy_single(&_vgname_hash);
+		_hash_destroy_single(&_pvname_hash);
+		_hash_destroy_single(&_lvname_hash);
+		return 0;
+	}
+	return 1;
+}
+
+static vg_t *_lookup_vg_by_name(char **argv, int argc)
+{
+	vg_t *vg;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return NULL;
+	}
+	if (!(vg = dm_hash_lookup(_vgid_hash, argv[1])) &&
+	    !(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("Can't find %s in open VGs - run vg_open first\n",
+			argv[1]);
+		return NULL;
+	}
+	return vg;
+}
+
+static void _vg_open(char **argv, int argc, lvm_t libh)
+{
+	vg_t *vg;
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+	struct dm_list *pvs;
+	struct lvm_pv_list *pvl;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	if ((vg = dm_hash_lookup(_vgid_hash, argv[1])) ||
+	    (vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("VG already open\n");
+		return;
+	}
+	/* FIXME: allow different open modes */
+	vg = lvm_vg_open(libh, argv[1], "r", 0);
+	if (!vg || !lvm_vg_get_name(vg)) {
+		printf("Error opening %s\n", argv[1]);
+		return;
+	}
+
+	printf("Success opening vg %s\n", argv[1]);
+	dm_hash_insert(_vgname_hash, lvm_vg_get_name(vg), vg);
+	dm_hash_insert(_vgid_hash, lvm_vg_get_uuid(vg), vg);
+
+	/*
+	 * Add the LVs and PVs into the hashes for lookups
+	 */
+	lvs = lvm_vg_list_lvs(vg);
+	dm_list_iterate_items(lvl, lvs) {
+		/* Concatenate VG name with LV name */
+		dm_hash_insert(_lvname_hash, lvm_lv_get_name(lvl->lv), lvl->lv);
+	}
+	pvs = lvm_vg_list_pvs(vg);
+	dm_list_iterate_items(pvl, pvs) {
+		dm_hash_insert(_pvname_hash, lvm_pv_get_name(pvl->pv), pvl->pv);
+	}
+}
+
+static void _vg_close(char **argv, int argc)
+{
+	vg_t *vg;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	while((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
+		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
+		lvm_vg_close(vg);
+	}
+	while((vg = dm_hash_lookup(_vgid_hash, argv[1]))) {
+		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
+		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
+		lvm_vg_close(vg);
+	}
+}
+
+static void _show_one_vg(vg_t *vg)
+{
+	/* FIXME: uuid is not null terminated */
+	printf("%s (%s): mode = %s\n", lvm_vg_get_name(vg),
+	       lvm_vg_get_uuid(vg), "READ");
+}
+
+static void _list_open_vgs(void)
+{
+	dm_hash_iter(_vgid_hash, (dm_hash_iterate_fn) _show_one_vg);
+}
+
+static void _pvs_in_vg(char **argv, int argc)
+{
+	struct dm_list *pvs;
+	struct lvm_pv_list *pvl;
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	pvs = lvm_vg_list_pvs(vg);
+	if (!pvs || dm_list_empty(pvs)) {
+		printf("No PVs in VG %s\n", lvm_vg_get_name(vg));
+		return;
+	}
+	printf("PVs in VG %s:\n", lvm_vg_get_name(vg));
+	dm_list_iterate_items(pvl, pvs) {
+		printf("%s (%s)\n",
+		       lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv));
+	}
+}
+
+static void _lvs_in_vg(char **argv, int argc)
+{
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	lvs = lvm_vg_list_lvs(vg);
+	if (!lvs || dm_list_empty(lvs)) {
+		printf("No LVs in VG %s\n", lvm_vg_get_name(vg));
+		return;
+	}
+	printf("LVs in VG %s:\n", lvm_vg_get_name(vg));
+	dm_list_iterate_items(lvl, lvs) {
+		printf("%s/%s (%s)\n", lvm_vg_get_name(vg),
+		       lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv));
+	}
+}
+
 static int lvmapi_test_shell(lvm_t libh)
 {
-	int argc, i;
+	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
+	_hash_create();
+	argc=0;
 	while (1) {
 		free(input);
 		input = readline("lvm> ");
@@ -86,17 +279,28 @@
 			printf("Exiting.\n");
 			break;
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
-			printf("No commands defined\n");
-		} else if (!strcmp(argv[0], "scan")) {
-			for (i=1; i < argc; i++)
-				printf("Scan a path!\n");
+			_show_help();
+		} else if (!strcmp(argv[0], "vg_open")) {
+			_vg_open(argv, argc, libh);
+		} else if (!strcmp(argv[0], "vg_close")) {
+			_vg_close(argv, argc);
+		} else if (!strcmp(argv[0], "vgs_open")) {
+			_list_open_vgs();
+		} else if (!strcmp(argv[0], "vg_list_pvs")) {
+			_pvs_in_vg(argv, argc);
+		} else if (!strcmp(argv[0], "vg_list_lvs")) {
+			_lvs_in_vg(argv, argc);
+		} else {
+			printf ("Unrecognized command %s\n", argv[0]);
 		}
 	}
 
+	dm_hash_iter(_vgname_hash, (dm_hash_iterate_fn) lvm_vg_close);
+	_hash_destroy();
 	free(input);
 	return 0;
 }
-		      
+
 int main (int argc, char *argv[])
 {
 	lvm_t libh;


