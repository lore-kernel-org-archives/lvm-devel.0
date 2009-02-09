From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:08 -0500
Subject: [PATCH 20/21] Update test code to use new lvm_get_vg_attr_list(), list from lvm_vg_open().
In-Reply-To: <1234153329-2829-20-git-send-email-dwysocha@redhat.com>
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
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-15-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-16-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-17-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-18-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-19-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-20-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-21-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The updated lvm_vg_open() stores the list of vg attributes at open
time.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   84 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 45 insertions(+), 39 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 0255a00..e127cc2 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -218,6 +218,35 @@ static void get_and_print_pv_attr(lvm_pv_obj_t *pv, const char *name)
 	_print_attr(name, value);
 }
 
+static void _show_one_vg(vg_t *vg)
+{
+	/* FIXME: uuid is not null terminated */
+	printf("%s (%s): mode = %s\n", lvm_vg_name(vg),
+	       lvm_vg_uuid(vg),
+	       lvm_vg_mode(vg) == O_RDWR ? "READ/WRITE" :
+	       lvm_vg_mode(vg) == O_RDONLY ? "READ" :
+	       "UNKNOWN");
+}
+static void _list_open_vgs(void)
+{
+	dm_hash_iter(_vgid_hash, (dm_hash_iterate_fn) _show_one_vg);
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
+		vgname = vgname_from_vgid(NULL, vgid->str);
+		printf("%s, %s\n", vgname, vgid->str);
+	}
+}
+
 static void _vg_open(char **argv, int argc, lvm_handle_t libh)
 {
 	vg_t *vg;
@@ -273,62 +302,39 @@ static void _vg_close(char **argv, int argc)
 		printf ("Please enter vg_name\n");
 		return;
 	}
-	if (!(vg = _lookup_vg_by_name(argv, argc)))
-		return;
-	dm_hash_remove(_vgid_hash, lvm_vg_uuid(vg));
-	dm_hash_remove(_vgname_hash, lvm_vg_name(vg));
-	lvm_vg_close(vg);
-}	
-
-static void _show_one_vg(vg_t *vg)
-{
-	/* FIXME: uuid is not null terminated */
-	printf("%s (%s): mode = %s\n", lvm_vg_name(vg),
-	       lvm_vg_uuid(vg),
-	       lvm_vg_mode(vg) == O_RDWR ? "READ/WRITE" :
-	       lvm_vg_mode(vg) == O_RDONLY ? "READ" :
-	       "UNKNOWN");
-}
-static void _list_open_vgs(void)
-{
-	dm_hash_iter(_vgid_hash, (dm_hash_iterate_fn) _show_one_vg);
-}
-
-void _list_all_vgs(lvm_handle_t libh)
-{
-	struct dm_list *vgids;
-	struct str_list *vgid;
-	const char *vgname;
-
-	/* FIXME: properly export str_list and API function */
-	vgids = lvm_get_vgids(libh);
-	dm_list_iterate_items(vgid, vgids) {
-		vgname = vgname_from_vgid(NULL, vgid->str);
-		printf("%s, %s\n", vgname, vgid->str);
+	while((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+		dm_hash_remove(_vgid_hash, lvm_vg_uuid(vg));
+		dm_hash_remove(_vgname_hash, lvm_vg_name(vg));
+		lvm_vg_close(vg);
 	}
-}
+	while((vg = dm_hash_lookup(_vgid_hash, argv[1]))) {
+		dm_hash_remove(_vgid_hash, lvm_vg_uuid(vg));
+		dm_hash_remove(_vgname_hash, lvm_vg_name(vg));
+		lvm_vg_close(vg);
+	}
+}	
 
 static void _vg_get_attr_list(char **argv, int argc)
 {
 	struct dm_report_field_ids_type *field;
-	struct dm_list fields;
+	struct dm_list *fields;
 	vg_t *vg;
 
 	if (!(vg = _lookup_vg_by_name(argv, argc)))
 		return;
-	if (!lvm_vg_get_attr_list(vg, &fields)) {
+	if (!(fields = lvm_vg_get_attr_list(vg))) {
 		printf("Error reading vg attribute list\n");
 		return;
 	}
 	printf("VG attribute names:\n");
-	dm_list_iterate_items(field, &fields) {
+	dm_list_iterate_items(field, fields) {
 		printf("%s\n", field->id);
 	}
 }
 
 static void _vg_get_attr_value(char **argv, int argc)
 {
-	struct dm_list fields;
+	struct dm_list *fields;
 	struct dm_report_field_ids_type *field;
 	int i;
 	vg_t *vg;
@@ -340,11 +346,11 @@ static void _vg_get_attr_value(char **argv, int argc)
 			get_and_print_vg_attr(vg, argv[i]);
 		return;
 	}
-	if (!lvm_vg_get_attr_list(vg, &fields)) {
+	if (!(fields = lvm_vg_get_attr_list(vg))) {
 		printf("Error reading vg attribute list\n");
 		return;
 	}
-	dm_list_iterate_items(field, &fields) {
+	dm_list_iterate_items(field, fields) {
 		get_and_print_vg_attr(vg, field->id);
 	}
 }
-- 
1.6.0.5


