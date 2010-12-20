From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 12:29:40 -0000
Subject: LVM2/test/api percent.c
Message-ID: <20101220122940.25360.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 12:29:39

Modified files:
	test/api       : percent.c 

Log message:
	Move var declarations to function begining
	
	As assert macro jumps to 'bad:' label - we need vg initialized.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/api/percent.c	2010/12/14 23:20:59	1.1
+++ LVM2/test/api/percent.c	2010/12/20 12:29:39	1.2
@@ -4,16 +4,21 @@
 
 int main(int argc, char *argv[])
 {
-        lvm_t handle = lvm_init(NULL);
+	lvm_t handle;
+	vg_t vg = NULL;
+	lv_t lv;
+	struct lvm_property_value v;
+
+	handle = lvm_init(NULL);
         assert(handle);
 
-	vg_t vg = lvm_vg_open(handle, argv[1], "r", 0);
+	vg = lvm_vg_open(handle, argv[1], "r", 0);
         assert(vg);
 
-        lv_t lv = lvm_lv_from_name(vg, "snap");
+	lv = lvm_lv_from_name(vg, "snap");
         assert(lv);
 
-        struct lvm_property_value v = lvm_lv_get_property(lv, "snap_percent");
+        v = lvm_lv_get_property(lv, "snap_percent");
         assert(v.is_valid);
         assert(v.value.integer == PERCENT_0);
 


