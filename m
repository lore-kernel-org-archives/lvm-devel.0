From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 12 Feb 2009 14:30:41 -0500
Subject: [PATCH 12/12] Add test code.
In-Reply-To: <1234467041-21522-12-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-9-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-10-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-11-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-12-git-send-email-dwysocha@redhat.com>
Message-ID: <1234467041-21522-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm_vg_open, lvm_vg_close()
vg_get_attr_list and vg_get_attr
lvs_in_vg(), pvs_in_vg()

- don't ignore orphan vg names (e.g. #orphan_lvm2) but allow comments
- when vg_open called, store vg, lvs, and pvs inside hashes for later lookup

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |  244 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 235 insertions(+), 9 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 9411663..82bd7ae 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004, 2009 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -29,7 +29,7 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 		while (*b && isspace(*b))
 			b++;
 
-		if ((!*b) || (*b == '#'))
+		if ((!*b) || ((*argc == 0)&&(*b == '#')))
 			break;
 
 		e = b;
@@ -48,11 +48,224 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static int lvmapi_test_shell(lvm_handle_t libh)
+static void _show_help(void)
 {
-	int argc, i;
+	printf("'pvs_in_vg vgname': "
+	       "Issue lvm_pvs_in_vg() API; must follow vg_open\n");
+	printf("'vgs_open': "
+	       "List the VGs that are currently open\n");
+	printf("'vgs': "
+	       "List all VGs known to the system\n");
+	printf("'vg_open vgname ['r' | 'w']': "
+	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
+	printf("'vg_close vgname': "
+	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'vg_get_attr_list vgname':"
+	       "Issue lvm_vg_get_attr_list() API; must follow vg_open\n");
+	printf("'vg_get_attr_value vgname [attr_name]':"
+	       "Issue lvm_vg_get_attr_value() API; must follow vg_open\n");
+	printf("'lvs_in_vg vgname': "
+	       "Issue lvm_lvs_in_vg() API; must follow vg_open\n");
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
+static void _print_attr(struct dm_report_attribute_type *attr)
+{
+	if (attr->is_string)
+		printf("%s = %s\n", attr->name, attr->u.s_val);
+	else
+		printf("%s = %llu\n", attr->name, (unsigned long long)attr->u.n_val);
+}
+static void get_and_print_vg_attr(vg_t *vg, const char *name)
+{
+	struct dm_report_attribute_type *attr;
+
+	if (!(attr = lvm_vg_get_attr(vg, name))) {
+		printf("Error reading vg attribute %s value \n",
+		       name);
+		return;
+	}
+	_print_attr(attr);
+}
+static void _vg_open(char **argv, int argc, lvm_handle_t libh)
+{
+	vg_t *vg;
+	mode_t mode;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	if ((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		printf ("VG already open\n");
+		return;
+	}
+	if ((argc == 3) && (argv[2][0] == 'w')) {
+		mode = O_RDWR;
+	} else
+		mode = O_RDONLY;
+	vg = lvm_vg_open(libh, argv[1], mode);
+	if (!vg) {
+		printf("Error opening %s: %s\n", argv[1],
+		       lvm_strerror(libh));
+		return;
+	}
+
+	printf("Success opening vg %s\n", argv[1]);
+	dm_hash_insert(_vgname_hash, lvm_vg_name(vg), vg);
+
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
+	while((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		dm_hash_remove(_vgname_hash, lvm_vg_name(vg));
+		lvm_vg_close(vg);
+	}
+}
+
+static void _show_one_vg(vg_t *vg)
+{
+	printf("%s: mode = %s\n", lvm_vg_name(vg),
+	       lvm_vg_mode(vg) == O_RDWR ? "READ/WRITE" :
+	       lvm_vg_mode(vg) == O_RDONLY ? "READ" :
+	       "UNKNOWN");
+}
+
+static void _list_open_vgs(void)
+{
+	dm_hash_iter(_vgname_hash, (dm_hash_iterate_fn) _show_one_vg);
+}
+
+static void _list_all_vgs(lvm_handle_t libh)
+{
+	struct dm_list *vgids;
+	struct str_list *vgid;
+	const char *vgname;
+
+	/* FIXME: properly export str_list and API function */
+	vgids = lvm_get_vgids(libh);
+	dm_list_iterate_items(vgid, vgids) {
+		vgname = lvm_vgname_from_vgid(libh, vgid->str);
+		printf("%s (%s)\n", vgname, vgid->str);
+	}
+}
+
+static void _vg_get_attr_list(char **argv, int argc)
+{
+	struct dm_report_attribute_type *attr;
+	struct dm_list *attrs;
+	vg_t *vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (!(attrs = lvm_vg_get_attr_list(vg))) {
+		printf("Error reading vg attribute list\n");
+		return;
+	}
+	printf("VG attribute names:\n");
+	dm_list_iterate_items(attr, attrs) {
+		printf("%s\n", attr->name);
+	}
+}
+
+static void _vg_get_attr_value(char **argv, int argc)
+{
+	struct dm_report_attribute_type *attr;
+	struct dm_list *attrs;
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
+	if (!(attrs = lvm_vg_get_attr_list(vg))) {
+		printf("Error reading vg attribute list\n");
+		return;
+	}
+	dm_list_iterate_items(attr, attrs) {
+		_print_attr(attr);
+	}
+}
+
+int lvmapi_test_shell(lvm_handle_t libh)
+{
+	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
+	_hash_create();
+	argc=0;
 	while (1) {
 		free(input);
 		input = readline("lvm> ");
@@ -86,17 +299,30 @@ static int lvmapi_test_shell(lvm_handle_t libh)
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
 	lvm_handle_t libh;
-- 
1.6.0.6


