From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:01 -0500
Subject: [PATCH 13/21] Add test code.
In-Reply-To: <1234153329-2829-13-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-14-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test lvm_pv_list, lvm_lv_get_attr_list, lvm_lv_get_attr_value().
pv_obj_get(), pv_obj_get_attr_list(), pv_obj_get_attr_value,
vg_get_attr_list and vg_get_attr_value,
lv_get_attr_list and lv_get_attr_value,
lvs_in_vg(), pvs_in_vg()
lvm_vg_open, lvm_vg_close().

- modularize code more
- don't ignore orphan vg names (e.g. #orphan_lvm2) but allow comments
- when vg_open called, store vg, lvs, and pvs inside hashes for later lookup
- allow lv attr value display by vgname/lvname

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |  487 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 480 insertions(+), 7 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 9411663..e7137f0 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -29,7 +29,7 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 		while (*b && isspace(*b))
 			b++;
 
-		if ((!*b) || (*b == '#'))
+		if ((!*b) || ((*argc == 0)&&(*b == '#')))
 			break;
 
 		e = b;
@@ -48,11 +48,457 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static int lvmapi_test_shell(lvm_handle_t libh)
+static void _show_help(void)
 {
-	int argc, i;
+	printf("'pvs_in_vg vgname': "
+	       "Issue lvm_pvs_in_vg() API; must follow vg_open\n");
+	printf("'pv_obj_get pvname': "
+	       "Issue a lvm_pv_obj_get() API call on PV 'pvname'\n");
+	printf("'pv_obj_get_attr_list': "
+	       "Issue lvm_pv_obj_get_attr_list() API; must follow pv_obj_get\n");
+	printf("'pv_obj_get_attr_value [attr_name]':"
+	       "Issue lvm_pv_obj_get_attr_value() API; must follow pv_obj_get\n");
+	printf("'vgs_open': "
+	       "List the VGs that are currently open\n");
+	printf("'vgs': "
+	       "List all VGs known to the system\n");
+	printf("'vg_open vgname': "
+	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
+	printf("'vg_close vgname': "
+	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'vg_get_attr_list vgname':"
+	       "Issue lvm_vg_get_attr_list() API; must follow vg_open\n");
+	printf("'vg_get_attr_value vgname [attr_name]':"
+	       "Issue lvm_vg_get_attr_value() API; must follow vg_open\n");
+	printf("'lvs_in_vg vgname': "
+	       "Issue lvm_lvs_in_vg() API; must follow vg_open\n");
+	printf("'lv_get_attr_list vgname/lvname': "
+	       "Issue lvm_lv_get_attr_list() API; must follow vg_open\n");
+	printf("'lv_get_attr_value vgname/lvname [attr_name]': "
+	       "Issue lvm_lv_get_attr_value() API; must follow vg_open\n");
+	printf("'quit': exit the program\n");
+}
+
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
+	if (!(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("Can't find %s in open VGs - run vg_open first\n",
+			argv[1]);
+		return NULL;
+	}
+	if (vg_read_error(vg)) {
+		printf("Error on VG - try vg_close/vg_open\n");
+		return NULL;
+	}
+	return vg;
+}
+
+static pv_t *_lookup_pv_by_name(char **argv, int argc)
+{
+	pv_t *pv;
+
+	if (argc < 2) {
+		printf ("Please enter pv_name\n");
+		return NULL;
+	}
+	if (!(pv = dm_hash_lookup(_pvname_hash, argv[1]))) {
+		printf ("Can't find %s in open VGs - run vg_open first\n",
+			argv[1]);
+		return NULL;
+	}
+	return pv;
+}
+
+static lv_t *_lookup_lv_by_name(char *lv_name)
+{
+	lv_t *lv;
+
+	if (!(lv = dm_hash_lookup(_lvname_hash, lv_name))) {
+		printf ("Can't find %s in open VGs - run vg_open first\n",
+			lv_name);
+		return NULL;
+	}
+	return lv;
+}
+
+static void _print_attr(const char *name,
+			struct dm_report_field_value_type value)
+{
+	if (value.is_string)
+		printf("%s = %s\n", name, value.u.s_val);
+	else
+		printf("%s = %llu\n", name, (unsigned long long)value.u.n_val);
+}
+
+static void get_and_print_vg_attr(vg_t *vg, const char *name)
+{
+	struct dm_report_field_value_type value;
+
+	if (!lvm_vg_get_attr_value(vg, name, &value)) {
+		printf("Error reading vg attribute %s value \n",
+		       name);
+		return;
+	}
+	_print_attr(name, value);
+}
+
+static void get_and_print_lv_attr(lv_t *lv, const char *name)
+{
+	struct dm_report_field_value_type value;
+
+	if (!lvm_lv_get_attr_value(lv, name, &value)) {
+		printf("Error reading lv attribute %s value \n",
+		       name);
+		return;
+	}
+	_print_attr(name, value);
+}
+
+static void get_and_print_pv_attr(lvm_pv_obj_t *pv, const char *name)
+{
+	struct dm_report_field_value_type value;
+
+	if (!lvm_pv_obj_get_attr_value(pv, name, &value)) {
+		printf("Error reading pv attribute %s value \n",
+		       name);
+		return;
+	}
+	_print_attr(name, value);
+}
+
+static void _vg_open(char **argv, int argc, lvm_handle_t libh)
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
+	if ((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("VG already open\n");
+		return;
+	}
+	vg = lvm_vg_open(libh, argv[1], O_RDONLY);
+	if (vg_read_error(vg)) {
+		printf("Error opening vg %s\n", argv[1]);
+		return;
+	}
+
+	printf("Success opening vg %s\n", argv[1]);
+	dm_hash_insert(_vgname_hash, lvm_vg_name(vg), vg);
+
+	/*
+	 * Add the LVs and PVs into the hashes for lookups
+	 */
+	lvs = lvm_lvs_in_vg(vg);
+	dm_list_iterate_items(lvl, lvs) {
+		/* Concatenate VG name with LV name */
+		dm_hash_insert(_lvname_hash, lvm_lv_name(lvl->lv), lvl->lv);
+	}
+	pvs = lvm_pvs_in_vg(vg);
+	dm_list_iterate_items(pvl, pvs) {
+		dm_hash_insert(_pvname_hash, lvm_pv_name(pvl->pv), pvl->pv);
+	}
+}
+
+static void _vg_close(char **argv, int argc)
+{
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	if (!(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("Can't find %s in open VGs - run vg_open first\n",
+			argv[1]);
+		return;
+	}
+	dm_hash_remove(_vgname_hash, lvm_vg_name(vg));
+	lvm_vg_close(vg);
+}	
+
+static void _show_one_vg(vg_t *vg)
+{
+	/* FIXME: store / display actual open mode */
+	printf("%s: mode = READ\n", lvm_vg_name(vg));
+}
+static void _list_open_vgs(void)
+{
+	dm_hash_iter(_vgname_hash, (dm_hash_iterate_fn) _show_one_vg);
+}
+
+static void _list_all_vgs(lvm_handle_t libh)
+{
+	struct dm_list *vgnames;
+	struct str_list *vgname;
+
+	/* FIXME: properly export str_list and API function */
+	vgnames = get_vgnames(libh, 0);
+	dm_list_iterate_items(vgname, vgnames) {
+		printf("%s\n", vgname->str);
+	}
+}
+
+static void _vg_get_attr_list(char **argv, int argc)
+{
+	struct dm_report_field_ids_type *field;
+	struct dm_list fields;
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (!lvm_vg_get_attr_list(vg, &fields)) {
+		printf("Error reading vg attribute list\n");
+		return;
+	}
+	printf("VG attribute names:\n");
+	dm_list_iterate_items(field, &fields) {
+		printf("%s\n", field->id);
+	}
+}
+
+static void _vg_get_attr_value(char **argv, int argc)
+{
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+	int i;
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (argc > 2) {
+		for (i=2; i<argc; i++)
+			get_and_print_vg_attr(vg, argv[i]);
+		return;
+	}
+	if (!lvm_vg_get_attr_list(vg, &fields)) {
+		printf("Error reading vg attribute list\n");
+		return;
+	}
+	dm_list_iterate_items(field, &fields) {
+		get_and_print_vg_attr(vg, field->id);
+	}
+}
+
+static void _pv_obj_get(char **argv, int argc, lvm_pv_obj_t **pvp,
+			lvm_handle_t libh)
+{
+	if (argc < 2) {
+		printf ("Please enter pv_name\n");
+		return;
+	}
+	if (!(*pvp = lvm_pv_obj_get(libh, argv[1], "r")))
+		printf("Error opening PV %s\n", argv[1]);
+	else
+		printf("Success opening PV %s\n", argv[1]);
+}
+
+static void _pv_obj_get_attr_list(lvm_pv_obj_t *pv)
+{
+	struct dm_report_field_ids_type *field;
+	struct dm_list fields;
+
+	if (!pv) {
+		printf("Run pv_obj_get first\n");
+		return;
+			}
+	if (!lvm_pv_obj_get_attr_list(pv, &fields)) {
+		printf("Error reading pv attribute list\n");
+		return;
+	}
+	printf("PV attribute names:\n");
+	dm_list_iterate_items(field, &fields) {
+		printf("%s\n", field->id);
+	}
+}
+
+static void _pv_obj_get_attr_value(char **argv, int argc,
+				   lvm_pv_obj_t *pv)
+{
+	struct dm_report_field_ids_type *field;
+	struct dm_list fields;
+	int i;
+
+	if (!pv) {
+		printf("Run pv_obj_get first\n");
+		return;
+	}
+	if (argc > 1) {
+		for (i=1; i<argc; i++)
+			get_and_print_pv_attr(pv, argv[i]);
+		return;
+	}
+	if (!lvm_pv_obj_get_attr_list(pv, &fields)) {
+		printf("Error reading pv attribute list\n");
+		return;
+	}
+	dm_list_iterate_items(field, &fields) {
+		get_and_print_pv_attr(pv, field->id);
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
+	lvs = lvm_lvs_in_vg(vg);
+	if (dm_list_empty(lvs)) {
+		printf("No LVs in VG %s\n", lvm_vg_name(vg));
+		return;
+	}
+	printf("LVs in VG %s:\n", lvm_vg_name(vg));
+	dm_list_iterate_items(lvl, lvs) {
+		printf("%s/%s\n", lvm_vg_name(vg), lvm_lv_name(lvl->lv));
+	}
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
+	pvs = lvm_pvs_in_vg(vg);
+	if (dm_list_empty(pvs)) {
+		printf("No PVs in VG %s\n", lvm_vg_name(vg));
+		return;
+	}
+	printf("PVs in VG %s:\n", lvm_vg_name(vg));
+	dm_list_iterate_items(pvl, pvs) {
+		printf("%s\n", lvm_pv_name(pvl->pv));
+	}
+}
+
+static void _lv_get_attr_list(char **argv, int argc)
+{
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+	vg_t *vg;
+	char *slash;
+	lv_t *lv;
+
+	/*
+	 * cmdline should be: vgname/lvname
+	 */
+	slash = strchr(argv[1], '/');
+	if (argc < 2 || !slash) {
+		printf("Invalid commandline - please enter vgname/lvname");
+	}
+	slash[0] ='\0';
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (!strlen(slash+1) || !(lv = _lookup_lv_by_name(slash+1)))
+		return;
+	if (!lvm_lv_get_attr_list(lv, &fields)) {
+		printf("Error reading lv attribute list\n");
+		return;
+	}
+	printf("LV attribute names:\n");
+	dm_list_iterate_items(field, &fields) {
+		printf("%s\n", field->id);
+	}
+}
+
+static void _lv_get_attr_value(char **argv, int argc)
+{
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+	int i;
+	vg_t *vg;
+	char *slash;
+	lv_t *lv;
+
+	/*
+	 * cmdline should be: vgname/lvname
+	 */
+	slash = strchr(argv[1], '/');
+	if (argc < 2 || !slash) {
+		printf("Invalid commandline - please enter vgname/lvname");
+	}
+	slash[0] ='\0';
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (!strlen(slash+1) || !(lv = _lookup_lv_by_name(slash+1)))
+		return;
+	if (!lvm_lv_get_attr_list(lv, &fields)) {
+		printf("Error reading lv attribute list\n");
+		return;
+	}
+	if (argc > 2) {
+		for (i=2; i<argc; i++)
+			get_and_print_lv_attr(lv, argv[i]);
+		return;
+	}
+	dm_list_iterate_items(field, &fields) {
+		get_and_print_lv_attr(lv, field->id);
+	}
+}
+
+
+int lvmapi_test_shell(lvm_handle_t libh)
+{
+	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
+	lvm_pv_obj_t *pv = NULL;
 
+	_hash_create();
+	argc=0;
 	while (1) {
 		free(input);
 		input = readline("lvm> ");
@@ -86,13 +532,40 @@ static int lvmapi_test_shell(lvm_handle_t libh)
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
+		} else if (!strcmp(argv[0], "vgs")) {
+			_list_all_vgs(libh);
+		} else if (!strcmp(argv[0], "vg_get_attr_list")) {
+			_vg_get_attr_list(argv, argc);
+		} else if (!strcmp(argv[0], "vg_get_attr_value")) {
+			_vg_get_attr_value(argv, argc);
+		} else if (!strcmp(argv[0], "pvs_in_vg")) {
+			_pvs_in_vg(argv, argc);
+		} else if (!strcmp(argv[0], "pv_obj_get")) {
+			_pv_obj_get(argv, argc, &pv, libh);
+		} else if (!strcmp(argv[0], "pv_obj_get_attr_list")) {
+			_pv_obj_get_attr_list(pv);
+		} else if (!strcmp(argv[0], "pv_obj_get_attr_value")) {
+			_pv_obj_get_attr_value(argv, argc, pv);
+		} else if (!strcmp(argv[0], "lvs_in_vg")) {
+			_lvs_in_vg(argv, argc);
+		} else if (!strcmp(argv[0], "lv_get_attr_list")) {
+			_lv_get_attr_list(argv, argc);
+		} else if (!strcmp(argv[0], "lv_get_attr_value")) {
+			_lv_get_attr_value(argv, argc);
+		} else {
+			printf ("Unrecognized command %s\n", argv[0]);
 		}
 	}
 
+	dm_hash_iter(_vgname_hash, (dm_hash_iterate_fn) lvm_vg_close);
+	_hash_destroy();
 	free(input);
 	return 0;
 }
-- 
1.6.0.5


