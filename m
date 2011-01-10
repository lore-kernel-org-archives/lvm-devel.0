From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:07:59 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm_misc.c
Message-ID: <20110110130759.5582.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:07:58

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm_misc.c 

Log message:
	Add default error path for get_property
	
	Set invalid property value for error path when NULL handler is passed.
	Fixes use of uninitialized prop structure as we return 'v' by value.
	---

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1865&r2=1.1866
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2011/01/10 13:00:53	1.1865
+++ LVM2/WHATS_NEW	2011/01/10 13:07:58	1.1866
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Detect NULL handle in get_property().
   Fix superfluous /usr in ocf_scriptdir instalation path.
   Add --with-ocfdir configurable option.
   Add aclocal.m4 (for pkgconfig).
--- LVM2/liblvm/lvm_misc.c	2010/12/14 23:20:58	1.7
+++ LVM2/liblvm/lvm_misc.c	2011/01/10 13:07:58	1.8
@@ -52,33 +52,29 @@
 	struct lvm_property_type prop;
 	struct lvm_property_value v;
 
+	memset(&v, 0, sizeof(v));
 	prop.id = name;
+
 	if (pv) {
-		if (!pv_get_property(pv, &prop)) {
-			v.is_valid = 0;
+		if (!pv_get_property(pv, &prop))
 			return v;
-		}
 	} else if (vg) {
-		if (!vg_get_property(vg, &prop)) {
-			v.is_valid = 0;
+		if (!vg_get_property(vg, &prop))
 			return v;
-		}
 	} else if (lv) {
-		if (!lv_get_property(lv, &prop)) {
-			v.is_valid = 0;
+		if (!lv_get_property(lv, &prop))
 			return v;
-		}
 	} else if (lvseg) {
-		if (!lvseg_get_property(lvseg, &prop)) {
-			v.is_valid = 0;
+		if (!lvseg_get_property(lvseg, &prop))
 			return v;
-		}
 	} else if (pvseg) {
-		if (!pvseg_get_property(pvseg, &prop)) {
-			v.is_valid = 0;
+		if (!pvseg_get_property(pvseg, &prop))
 			return v;
-		}
+	} else {
+		log_errno(EINVAL, "Invalid NULL handle passed to library function.");
+		return v;
 	}
+
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
 	v.is_integer = prop.is_integer;


