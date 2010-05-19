From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 11:53:31 -0000
Subject: LVM2/test/api test.c
Message-ID: <20100519115331.25591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 11:53:30

Modified files:
	test/api       : test.c 

Log message:
	Test lvm_vgname_from_{pvid|device}.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/test/api/test.c	2010/02/24 18:16:35	1.29
+++ LVM2/test/api/test.c	2010/05/19 11:53:30	1.30
@@ -97,6 +97,10 @@
 	       "Add/remove a tag from a VG\n");
 	printf("'lv_{add|remove}_tag vgname lvname tag': "
 	       "Add/remove a tag from a LV\n");
+	printf("'vgname_from_devname device': "
+	       "Lookup a vgname from a device name\n");
+	printf("'vgname_from_pvid pvid': "
+	       "Lookup a vgname from a pvid\n");
 	printf("'quit': exit the program\n");
 }
 
@@ -576,6 +580,38 @@
 	printf("%s tag %s to LV %s\n",
 	       add ? "adding":"removing", argv[3], argv[2]);
 }
+static void _vgname_from_pvid(char **argv, int argc, lvm_t libh)
+{
+	const char *vgname;
+
+	if (argc < 1) {
+		printf("Please enter pvid\n");
+		return;
+	}
+	if (!(vgname = lvm_vgname_from_pvid(libh, argv[1]))) {
+		printf("Error ");
+	} else {
+		printf("Success ");
+	}
+	printf("looking up vgname=%s from PVID=%s\n",
+	       vgname, argv[1]);
+}
+static void _vgname_from_devname(char **argv, int argc, lvm_t libh)
+{
+	const char *vgname;
+
+	if (argc < 1) {
+		printf("Please enter device\n");
+		return;
+	}
+	if (!(vgname = lvm_vgname_from_device(libh, argv[1]))) {
+		printf("Error ");
+	} else {
+		printf("Success ");
+	}
+	printf("looking up vgname=%s from device name=%s\n",
+	       vgname, argv[1]);
+}
 static void _lvs_in_vg(char **argv, int argc)
 {
 	struct dm_list *lvs;
@@ -766,6 +802,10 @@
 			_lv_tag(argv, argc, 0);
 		} else if (!strcmp(argv[0], "lv_get_tags")) {
 			_lv_get_tags(argv, argc);
+		} else if (!strcmp(argv[0], "vgname_from_devname")) {
+			_vgname_from_devname(argv, argc, libh);
+		} else if (!strcmp(argv[0], "vgname_from_pvid")) {
+			_vgname_from_pvid(argv, argc, libh);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}


