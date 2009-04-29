From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:34 -0400
Subject: [PATCH 8/8] Update test/api/test.c for simple tests involving vg/lv name/uuid attributes.
In-Reply-To: <1241034934-25639-8-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-3-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-4-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-5-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-6-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-7-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Tests the following APIs:
- lvm_{vg|lv}_get_{name|uuid}()
- lvm_lvs_in_vg()

Example:
./test
lvm> vg_open vg1
Success opening vg vg1
lvm> vgs_open
vg1 (VeMEO8rGOfY44H8MWieFxIf26CKKpJNj): mode = READ
lvm> lvs_in_vg vg1
LVs in VG vg1:
vg1/lv1 (7phxOHwNPWS9wsqjkD22Fmd1vvLImYjm)
lvm> vg_close vg1
lvm> exit
Exiting.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |  204 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 196 insertions(+), 8 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index b742976..8217301 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -29,7 +29,7 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 		while (*b && isspace(*b))
 			b++;
 
-		if ((!*b) || (*b == '#'))
+		if ((!*b) || ((*argc == 0)&&(*b == '#')))
 			break;
 
 		e = b;
@@ -48,11 +48,190 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
+static void _show_help(void)
+{
+	printf("'lvs_in_vg vgname': "
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
+#if 0
+	struct dm_list *pvs;
+	struct lvm_pv_list *pvl;
+#endif
+	mode_t mode;
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
+	if ((argc == 3) && (argv[2][0] == 'w')) {
+		mode = O_RDWR;
+	} else
+		mode = O_RDONLY;
+	vg = lvm_vg_open(libh, argv[1], mode);
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
+	lvs = lvm_lvs_in_vg(vg);
+	dm_list_iterate_items(lvl, lvs) {
+		/* Concatenate VG name with LV name */
+		dm_hash_insert(_lvname_hash, lvm_lv_get_name(lvl->lv), lvl->lv);
+	}
+#if 0
+	pvs = lvm_pvs_in_vg(vg);
+	dm_list_iterate_items(pvl, pvs) {
+		dm_hash_insert(_pvname_hash, lvm_pv_name(pvl->pv), pvl->pv);
+	}
+#endif
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
+static void _lvs_in_vg(char **argv, int argc)
+{
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	lvs = lvm_lvs_in_vg(vg);
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
@@ -86,17 +265,26 @@ static int lvmapi_test_shell(lvm_t libh)
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
+		} else if (!strcmp(argv[0], "lvs_in_vg")) {
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
-- 
1.6.0.6


