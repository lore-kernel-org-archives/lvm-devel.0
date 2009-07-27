From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:02:51 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090727210251.12005.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:02:51

Modified files:
	test/api       : test.c 

Log message:
	Add config_reload and config_override to test.c, change prompt.
	
	PV         PV UUID                                VG
	/dev/loop1 A95EvV-iqmb-ZFuJ-u8MV-Npwn-wlc2-Ul1Mnn vg1
	/dev/loop0 R16FDG-OmoS-HNGt-LSZY-OAlC-7qeU-t2gztp vg1
	lvm> config_override loop0
	Success overriding LVM configuration
	lvm> config_reload
	Success reloading LVM configuration
	lvm> vg_open vg1
	Couldn't find device with uuid 'A95EvV-iqmb-ZFuJ-u8MV-Npwn-wlc2-Ul1Mnn'.
	Success opening vg vg1
	lvm> vg_close vg1
	lvm> quit
	
	Maybe a bug in lvm_vg_open for missing pvs but the filter seems to work.
	
	Change prompt from "lvm>" to "liblvm>".
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/test/api/test.c	2009/07/27 17:45:21	1.17
+++ LVM2/test/api/test.c	2009/07/27 21:02:51	1.18
@@ -80,6 +80,10 @@
 	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
 	printf("'vg_close vgname': "
 	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'config_reload': "
+	       "Issue a lvm_config_reload() API to reload LVM config\n");
+	printf("'config_override' device: "
+	       "Issue a lvm_config_override() with accept device filter\n");
 	printf("'quit': exit the program\n");
 }
 
@@ -221,6 +225,35 @@
 		_remove_device_from_pvname_hash(pvs, argv[2]);
 }
 
+static void _config_override(char **argv, int argc, lvm_t libh)
+{
+	int rc;
+	char tmp[64];
+
+	if (argc < 2) {
+		printf ("Please enter device\n");
+		return;
+	}
+	snprintf(tmp, 63, "devices{filter=[\"a|%s|\", \"r|.*|\"]}", argv[1]);
+	rc = lvm_config_override(libh, tmp);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("overriding LVM configuration\n");
+}
+
+static void _config_reload(char **argv, int argc, lvm_t libh)
+{
+	int rc;
+	rc = lvm_config_reload(libh);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("reloading LVM configuration\n");
+}
+
 static void _vg_extend(char **argv, int argc, lvm_t libh)
 {
 	vg_t *vg;
@@ -489,7 +522,7 @@
 	argc=0;
 	while (1) {
 		free(input);
-		input = readline("lvm> ");
+		input = readline("liblvm> ");
 
 		/* EOF */
 		if (!input) {
@@ -521,6 +554,10 @@
 			break;
 		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
 			_show_help();
+		} else if (!strcmp(argv[0], "config_reload")) {
+			_config_reload(argv, argc, libh);
+		} else if (!strcmp(argv[0], "config_override")) {
+			_config_override(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_extend")) {
 			_vg_extend(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_reduce")) {


