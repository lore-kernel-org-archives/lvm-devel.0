From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 09:56:49 -0000
Subject: LVM2/liblvm lvm.h lvm_lv.c lvm_pv.c lvm_vg.c
Message-ID: <20090728095649.16994.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 09:56:49

Modified files:
	liblvm         : lvm.h lvm_lv.c lvm_pv.c lvm_vg.c 

Log message:
	Use dm_malloc and dm_free in liblvm instead of malloc/free.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/liblvm/lvm.h	2009/07/28 09:16:18	1.35
+++ LVM2/liblvm/lvm.h	2009/07/28 09:56:48	1.36
@@ -407,8 +407,8 @@
 /**
  * Get the current name of a volume group.
  *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
@@ -419,8 +419,8 @@
 /**
  * Get the current uuid of a volume group.
  *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
@@ -557,8 +557,8 @@
 /**
  * Get the current name of a logical volume.
  *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
  *
  * \param   lv
  *          Logical volume handle.
@@ -569,8 +569,8 @@
 /**
  * Get the current uuid of a logical volume.
  *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
  *
  * \param   lv
  *          Logical volume handle.
@@ -638,8 +638,8 @@
 /**
  * Get the current uuid of a logical volume.
  *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
  *
  * \param   pv
  *          Physical volume handle.
@@ -650,8 +650,8 @@
 /**
  * Get the current name of a logical volume.
  *
- * Memory is allocated using malloc() and caller must free the memory
- * using free().
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
  *
  * \param   pv
  *          Physical volume handle.
--- LVM2/liblvm/lvm_lv.c	2009/07/27 21:03:15	1.9
+++ LVM2/liblvm/lvm_lv.c	2009/07/28 09:56:48	1.10
@@ -44,7 +44,7 @@
 {
 	char *name;
 
-	name = malloc(NAME_LEN + 1);
+	name = dm_malloc(NAME_LEN + 1);
 	strncpy(name, (const char *)lv->name, NAME_LEN);
 	name[NAME_LEN] = '\0';
 	return name;
--- LVM2/liblvm/lvm_pv.c	2009/07/27 21:03:15	1.4
+++ LVM2/liblvm/lvm_pv.c	2009/07/28 09:56:48	1.5
@@ -32,7 +32,7 @@
 {
 	char *name;
 
-	name = malloc(NAME_LEN + 1);
+	name = dm_malloc(NAME_LEN + 1);
 	strncpy(name, (const char *)pv_dev_name(pv), NAME_LEN);
 	name[NAME_LEN] = '\0';
 	return name;
--- LVM2/liblvm/lvm_vg.c	2009/07/27 21:03:15	1.20
+++ LVM2/liblvm/lvm_vg.c	2009/07/28 09:56:48	1.21
@@ -269,7 +269,7 @@
 {
 	char *name;
 
-	name = malloc(NAME_LEN + 1);
+	name = dm_malloc(NAME_LEN + 1);
 	strncpy(name, (const char *)vg->name, NAME_LEN);
 	name[NAME_LEN] = '\0';
 	return name;


