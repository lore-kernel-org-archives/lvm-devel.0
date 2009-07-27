From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 17:44:58 -0000
Subject: LVM2/test/api vgtest.c
Message-ID: <20090727174458.22424.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 17:44:58

Modified files:
	test/api       : vgtest.c 

Log message:
	Update test/api/vgtest.c to include lvm_vg_reduce.
	
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	Acked-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/api/vgtest.c	2009/07/26 20:29:56	1.5
+++ LVM2/test/api/vgtest.c	2009/07/27 17:44:58	1.6
@@ -26,8 +26,63 @@
 vg_t *vg;
 const char *vg_name = "my_vg";
 const char *device = "/dev/loop3";
+const char *device2 = "/dev/loop4";
 uint64_t size = 1024;
 
+#define vg_create(vg_name) \
+	printf("Creating VG %s\n", vg_name); \
+	vg = lvm_vg_create(handle, vg_name); \
+	if (!vg) { \
+		fprintf(stderr, "Error creating volume group %s\n", vg_name); \
+		goto bad; \
+	}
+#define vg_extend(vg, dev) \
+	printf("Extending VG %s by %s\n", vg_name, dev); \
+	status = lvm_vg_extend(vg, dev); \
+	if (status) { \
+		fprintf(stderr, "Error extending volume group %s " \
+			"with device %s\n", vg_name, dev); \
+		goto bad; \
+	}
+#define vg_commit(vg) \
+	printf("Committing VG %s to disk\n", vg_name); \
+	status = lvm_vg_write(vg); \
+	if (status) { \
+		fprintf(stderr, "Creation of volume group '%s' on " \
+			"device '%s' failed\n", \
+			lvm_vg_get_name(vg), device); \
+		goto bad; \
+	}
+#define vg_open(vg_name, mode) \
+	printf("Opening VG %s %s\n", vg_name, mode); \
+	vg = lvm_vg_open(handle, vg_name, mode, 0); \
+	if (!vg) { \
+		fprintf(stderr, "Error opening volume group %s\n", vg_name); \
+		goto bad; \
+	}
+#define vg_close(vg) \
+	printf("Closing VG %s\n", vg_name); \
+	if (lvm_vg_close(vg)) { \
+		fprintf(stderr, "Error closing volume group %s\n", vg_name); \
+		goto bad; \
+	}
+#define vg_reduce(vg, dev) \
+	printf("Reducing VG %s by %s\n", vg_name, dev); \
+	status = lvm_vg_reduce(vg, dev); \
+	if (status) { \
+		fprintf(stderr, "Error reducing volume group %s " \
+			"by device %s\n", vg_name, dev); \
+		goto bad; \
+	}
+#define vg_remove(vg) \
+	printf("Removing VG %s from system\n", vg_name); \
+	status = lvm_vg_remove(vg); \
+	if (status) { \
+		fprintf(stderr, "Revmoval of volume group '%s' failed\n", \
+			vg_name); \
+		goto bad; \
+	}
+
 int main(int argc, char *argv[])
 {
 	int status;
@@ -41,20 +96,8 @@
 		goto bad;
 	}
 
-	printf("Creating VG %s\n", vg_name);
-	vg = lvm_vg_create(handle, vg_name);
-	if (!vg) {
-		fprintf(stderr, "Error creating volume group %s\n", vg_name);
-		goto bad;
-	}
-
-	printf("Extending VG %s\n", vg_name);
-	status = lvm_vg_extend(vg, device);
-	if (status) {
-		fprintf(stderr, "Error extending volume group %s "
-			"with device %s\n", vg_name, device);
-		goto bad;
-	}
+	vg_create(vg_name);
+	vg_extend(vg, device);
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
@@ -65,38 +108,27 @@
 		goto bad;
 	}
 
-	printf("Committing VG %s to disk\n", vg_name);
-	status = lvm_vg_write(vg);
-	if (status) {
-		fprintf(stderr, "Creation of volume group '%s' on "
-			"device '%s' failed\n",
-			vg_name, device);
-		goto bad;
-	}
+	vg_commit(vg);
+	vg_close(vg);
 
-	printf("Closing VG %s\n", vg_name);
-	if (lvm_vg_close(vg))
-		goto bad;
-	printf("Re-opening VG %s for reading\n", vg_name);
-	vg = lvm_vg_open(handle, vg_name, "r", 0);
-	if (!vg)
-		goto bad;
-	printf("Closing VG %s\n", vg_name);
-	if (lvm_vg_close(vg))
-		goto bad;
-	printf("Re-opening VG %s for writing\n", vg_name);
-	vg = lvm_vg_open(handle, vg_name, "w", 0);
-	if (!vg)
-		goto bad;
-	printf("Removing VG %s from system\n", vg_name);
-	status = lvm_vg_remove(vg);
-	if (status) {
-		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
-			vg_name);
-		goto bad;
-	}
+	vg_open(vg_name, "r");
+	vg_close(vg);
+
+	vg_open(vg_name, "w");
+	vg_extend(vg, device2);
+	vg_reduce(vg, device);
+	vg_commit(vg);
+	vg_close(vg);
+
+	vg_open(vg_name, "w");
+	vg_extend(vg, device);
+	vg_commit(vg);
+	vg_close(vg);
+
+	vg_open(vg_name, "w");
+	vg_remove(vg);
+	vg_close(vg);
 
-	lvm_vg_close(vg);
 	lvm_destroy(handle);
 	printf("liblvm vgcreate unit test PASS\n");
 	_exit(0);


