From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Sep 2009 17:13:46 -0000
Subject: LVM2/test/api vgtest.c
Message-ID: <20090903171346.26318.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-03 17:13:46

Modified files:
	test/api       : vgtest.c 

Log message:
	Update lvm2app vgtest to take vgname and devices as parameters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/api/vgtest.c	2009/08/13 12:16:45	1.10
+++ LVM2/test/api/vgtest.c	2009/09/03 17:13:46	1.11
@@ -25,9 +25,9 @@
 
 lvm_t handle;
 vg_t vg;
-const char *vg_name = "my_vg";
-const char *device = "/dev/loop3";
-const char *device2 = "/dev/loop4";
+const char *vg_name;
+#define MAX_DEVICES 16
+const char *device[MAX_DEVICES];
 uint64_t size = 1024;
 
 #define vg_create(vg_name) \
@@ -51,7 +51,7 @@
 	if (status) { \
 		fprintf(stderr, "Creation of volume group '%s' on " \
 			"device '%s' failed\n", \
-			lvm_vg_get_name(vg), device); \
+			lvm_vg_get_name(vg), device[0]); \
 		goto bad; \
 	}
 #define vg_open(vg_name, mode) \
@@ -84,11 +84,29 @@
 		goto bad; \
 	}
 
+int init_vgtest(int argc, char *argv[])
+{
+	int i;
+
+	if (argc < 4) {
+		fprintf(stderr, "Usage: %s <vgname> <pv1> <pv2> [... <pvN> ]",
+			argv[0]);
+		return -1;
+	}
+	vg_name = argv[1];
+	for(i=2; i<MAX_DEVICES && i < argc; i++) {
+		device[i-2] = argv[i];
+	}
+	return 0;
+}
+
 int main(int argc, char *argv[])
 {
 	int status;
 
-	/* FIXME: input vgname, etc from cmdline */
+	if (init_vgtest(argc, argv) < 0)
+		goto bad;
+
 	/* FIXME: make the below messages verbose-only and print PASS/FAIL*/
 	printf("Opening LVM\n");
 	handle = lvm_init(NULL);
@@ -99,7 +117,7 @@
 
 	printf("Library version: %s\n", lvm_library_get_version());
 	vg_create(vg_name);
-	vg_extend(vg, device);
+	vg_extend(vg, device[0]);
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
@@ -117,13 +135,13 @@
 	vg_close(vg);
 
 	vg_open(vg_name, "w");
-	vg_extend(vg, device2);
-	vg_reduce(vg, device);
+	vg_extend(vg, device[1]);
+	vg_reduce(vg, device[0]);
 	vg_commit(vg);
 	vg_close(vg);
 
 	vg_open(vg_name, "w");
-	vg_extend(vg, device);
+	vg_extend(vg, device[0]);
 	vg_commit(vg);
 	vg_close(vg);
 


