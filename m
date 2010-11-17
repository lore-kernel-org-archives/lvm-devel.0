From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 19:17:08 -0000
Subject: LVM2/test/api test.c
Message-ID: <20101117191708.26936.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 19:17:07

Modified files:
	test/api       : test.c 

Log message:
	Add vg_set_property to the interactive lvm2app test program.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/test/api/test.c	2010/10/25 14:09:19	1.31
+++ LVM2/test/api/test.c	2010/11/17 19:17:07	1.32
@@ -97,6 +97,8 @@
 	       "Display the value of VG property\n");
 	printf("'pv_get_property pvname property_name': "
 	       "Display the value of PV property\n");
+	printf("'vg_set_property vgname property_name': "
+	       "Set the value of VG property\n");
 	printf("'lv_get_tags vgname lvname': "
 	       "List the tags of a LV\n");
 	printf("'vg_{add|remove}_tag vgname tag': "
@@ -652,6 +654,36 @@
 	_print_property_value(v);
 }
 
+static void _vg_set_property(char **argv, int argc)
+{
+	vg_t vg;
+	struct lvm_property_value value;
+	int rc;
+
+	if (argc < 4) {
+		printf("Please enter vgname, field_id, value\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	value = lvm_vg_get_property(vg, argv[2]);
+	if (!value.is_valid) {
+		printf("Error obtaining property value\n");
+		return;
+	}
+	if (value.is_string)
+		value.value.string = argv[3];
+	else
+		value.value.integer = atoi(argv[3]);
+	rc = lvm_vg_set_property(vg, argv[2], &value);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("setting value of property %s in VG %s\n",
+	       argv[2], argv[1]);
+}
+
 static void _lv_get_tags(char **argv, int argc)
 {
 	lv_t lv;
@@ -908,6 +940,8 @@
 			_vg_get_property(argv, argc);
 		} else if (!strcmp(argv[0], "pv_get_property")) {
 			_pv_get_property(argv, argc);
+		} else if (!strcmp(argv[0], "vg_set_property")) {
+			_vg_set_property(argv, argc);
 		} else if (!strcmp(argv[0], "lv_add_tag")) {
 			_lv_tag(argv, argc, 1);
 		} else if (!strcmp(argv[0], "lv_remove_tag")) {


