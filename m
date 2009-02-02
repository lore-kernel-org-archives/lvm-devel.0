From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:09 -0500
Subject: [PATCH 13/13] Add test code.
In-Reply-To: <1233607809-1087-13-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-10-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-11-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-12-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-13-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-14-git-send-email-dwysocha@redhat.com>
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

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |  322 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 317 insertions(+), 5 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 9411663..b996770 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -48,10 +48,299 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
+static void _show_help(void)
+{
+	printf("'pv_obj_get pvname': Issue a lvm_pv_obj_get() API call on PV 'pvname'\n");
+	printf("'pv_obj_get_attr_list': Issue lvm_pv_obj_get_attr_list() API; must follow pv_obj_get\n");
+	printf("'pv_obj_get_attr_value [attr_name]': Issue lvm_pv_obj_get_attr_value() API; must follow pv_obj_get\n");
+	printf("'vg_open vgname': Issue a lvm_vg_open() API call on VG 'vgname'\n");
+	printf("'vg_close vgname': Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'vg_get_attr_list': Issue lvm_vg_get_attr_list() API; must follow vg_open\n");
+	printf("'vg_get_attr_value [attr_name]': Issue lvm_vg_get_attr_value() API; must follow vg_open\n");
+	printf("'pvs_in_vg': Issue lvm_pvs_in_vg() API; must follow vg_open\n");
+	printf("'lv_get_attr_list': Issue lvm_lv_get_attr_list() API; must follow vg_open\n");
+	printf("'lv_get_attr_value [attr_name]': Issue lvm_lv_get_attr_value() API; must follow vg_open\n");
+	printf("'quit': exit the program\n");
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
+static void _vg_open(char **argv, int argc, vg_t **vgp, void *h)
+{
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	*vgp = lvm_vg_open(h, argv[1], O_RDONLY);
+	if (vg_read_error(*vgp))
+		printf("Error opening vg %s\n", argv[1]);
+	else
+		printf("Success opening vg %s\n", argv[1]);
+}
+
+static void _pv_obj_get(char **argv, int argc, lvm_pv_obj_t **pvp, void *h)
+{
+	if (argc < 2) {
+		printf ("Please enter pv_name\n");
+		return;
+	}
+	if (!(*pvp = lvm_pv_obj_get(h, argv[1], "r")))
+		printf("Error opening PV %s\n", argv[1]);
+	else
+		printf("Success opening PV %s\n", argv[1]);
+}
+
+static void _pv_obj_get_attr_list(lvm_pv_obj_t *pv, void *h)
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
+static void _vg_get_attr_list(vg_t *vg)
+{
+	struct dm_report_field_ids_type *field;
+	struct dm_list fields;
+
+	if (vg_read_error(vg)) {
+		printf("Run vg_open first\n");
+		return;
+	}
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
+static void _lvs_in_vg(vg_t *vg)
+{
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+
+	if (vg_read_error(vg)) {
+		printf("Run vg_open first\n");
+		return;
+	}
+	lvs = lvm_lvs_in_vg(vg);
+	if (dm_list_empty(lvs)) {
+		printf("No LVs in VG %s\n", lvm_vg_name(vg));
+		return;
+	}
+	printf("LVs in VG %s:\n", lvm_vg_name(vg));
+	dm_list_iterate_items(lvl, lvs) {
+		printf("%s\n", lvm_lv_name(lvl->lv));
+	}
+}
+
+static void _pvs_in_vg(vg_t *vg)
+{
+	struct dm_list *pvs;
+	struct lvm_pv_list *pvl;
+
+	if (vg_read_error(vg)) {
+		printf("Run vg_open first\n");
+		return;
+	}
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
+static void _vg_get_attr_value(char **argv, int argc, vg_t *vg)
+{
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+	int i;
+
+	if (vg_read_error(vg)) {
+		printf("Run vg_open first\n");
+		return;
+	}
+	if (argc > 1) {
+		for (i=1; i<argc; i++)
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
+static void _lv_get_attr_list(vg_t *vg)
+{
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+
+	if (vg_read_error(vg)) {
+		printf("Run vg_open first\n");
+		return;
+	}
+	lvs = lvm_lvs_in_vg(vg);
+	lvl = (struct lvm_lv_list *) dm_list_first(lvs);
+	if (!lvl) {
+		printf("No LVs in VG %s\n",
+		       lvm_vg_name(vg));
+		return;
+	}
+	if (!lvm_lv_get_attr_list(lvl->lv, &fields)) {
+		printf("Error reading lv attribute list\n");
+		return;
+	}
+	printf("LV attribute names:\n");
+	dm_list_iterate_items(field, &fields) {
+		printf("%s\n", field->id);
+	}
+}
+
+static void _lv_get_attr_value(char **argv, int argc, vg_t *vg)
+{
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+	struct dm_list fields;
+	struct dm_report_field_ids_type *field;
+	int i;
+
+	if (vg_read_error(vg)) {
+		printf("Run vg_open first\n");
+		return;
+	}
+	lvs = lvm_lvs_in_vg(vg);
+	lvl = (struct lvm_lv_list *) dm_list_first(lvs);
+	if (!lvl) {
+		printf("No LVs in VG %s\n",
+		       lvm_vg_name(vg));
+		return;
+	}
+	if (!lvm_lv_get_attr_list(lvl->lv, &fields)) {
+		printf("Error reading lv attribute list\n");
+		return;
+	}
+	if (argc > 1) {
+		for (i=1; i<argc; i++)
+			get_and_print_lv_attr(lvl->lv,argv[i]);
+		return;
+	}
+	dm_list_iterate_items(field, &fields) {
+		get_and_print_lv_attr(lvl->lv, field->id);
+	}
+}
+
+static void _vg_close(char **argv, int argc, vg_t **vgp)
+{
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	if (!*vgp || (strcmp(argv[1], lvm_vg_name(*vgp)))) {
+		printf ("Run vg_open first\n");
+		return;
+	}
+	lvm_vg_close(*vgp);
+	*vgp = NULL;
+}	
+
 static int lvmapi_test_shell(lvm_handle_t libh)
 {
-	int argc, i;
+	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
+	vg_t *vg = NULL;
+	lvm_pv_obj_t *pv = NULL;
 
 	while (1) {
 		free(input);
@@ -86,12 +375,35 @@ static int lvmapi_test_shell(lvm_handle_t libh)
 			printf("Exiting.\n");
 			break;
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
-			printf("No commands defined\n");
-		} else if (!strcmp(argv[0], "scan")) {
-			for (i=1; i < argc; i++)
-				printf("Scan a path!\n");
+			_show_help();
+		} else if (!strcmp(argv[0], "vg_open")) {
+			_vg_open(argv, argc, &vg, libh);
+		} else if (!strcmp(argv[0], "vg_close")) {
+			_vg_close(argv, argc, &vg);
+		} else if (!strcmp(argv[0], "vg_get_attr_list")) {
+			_vg_get_attr_list(vg);
+		} else if (!strcmp(argv[0], "vg_get_attr_value")) {
+			_vg_get_attr_value(argv, argc, vg);
+		} else if (!strcmp(argv[0], "pvs_in_vg")) {
+			_pvs_in_vg(vg);
+		} else if (!strcmp(argv[0], "pv_obj_get")) {
+			_pv_obj_get(argv, argc, &pv, libh);
+		} else if (!strcmp(argv[0], "pv_obj_get_attr_list")) {
+			_pv_obj_get_attr_list(pv, libh);
+		} else if (!strcmp(argv[0], "pv_obj_get_attr_value")) {
+			_pv_obj_get_attr_value(argv, argc, pv);
+		} else if (!strcmp(argv[0], "lvs_in_vg")) {
+			_lvs_in_vg(vg);
+		} else if (!strcmp(argv[0], "lv_get_attr_list")) {
+			_lv_get_attr_list(vg);
+		} else if (!strcmp(argv[0], "lv_get_attr_value")) {
+			_lv_get_attr_value(argv, argc, vg);
+		} else {
+			printf ("Unrecognized command %s\n", argv[0]);
 		}
 	}
+	if (!vg_read_error(vg))
+		lvm_vg_close(vg);
 
 	free(input);
 	return 0;
-- 
1.5.5.1


