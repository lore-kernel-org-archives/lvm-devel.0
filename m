From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Dec 2011 15:18:32 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20111211151832.6306.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-11 15:18:32

Modified files:
	libdm          : libdm-config.c 

Log message:
	In the dm_config_*get_* functions, make the actual value retrieval optional
	(useful for just checking that a given key is of a given type).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/libdm/libdm-config.c	2011/10/28 20:07:38	1.15
+++ LVM2/libdm/libdm-config.c	2011/12/11 15:18:32	1.16
@@ -1111,7 +1111,8 @@
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
 
-	*result = n->v->v.i;
+	if (result)
+		*result = n->v->v.i;
 	return 1;
 }
 
@@ -1125,7 +1126,8 @@
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
 
-	*result = (uint64_t) n->v->v.i;
+	if (result)
+		*result = (uint64_t) n->v->v.i;
 	return 1;
 }
 
@@ -1139,7 +1141,8 @@
 	if (!n || !n->v || n->v->type != DM_CFG_STRING)
 		return 0;
 
-	*result = n->v->v.str;
+	if (result)
+		*result = n->v->v.str;
 	return 1;
 }
 
@@ -1154,7 +1157,8 @@
 	if (!n || !n->v)
 		return 0;
 
-	*result = n->v;
+	if (result)
+		*result = n->v;
 	return 1;
 }
 
@@ -1167,7 +1171,8 @@
 	if (!n || n->v)
 		return 0;
 
-	*result = n;
+	if (result)
+		*result = n;
 	return 1;
 }
 


