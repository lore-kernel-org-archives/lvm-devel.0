From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jul 2009 11:29:01 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/confi ...
Message-ID: <20090709112901.24931.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-07-09 11:29:01

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c config.h 
	lib/mirror     : mirrored.c 
	lib/striped    : striped.c 

Log message:
	Fix confusing metadata syntax error messages.
	
	If there is syntax error in metadata, it now prints messages
	like:
	Couldn't read 'start_extent' for segment 'extent_count'.
	Couldn't read all logical volumes for volume group vg_test.
	
	The segment specification is wrong and confusing.
	
	Patch fixes it by introducing "parent" member in config_node which
	points to parent section and config_parent_name function, which
	provides pointer to node section name.
	
	Also it adds several LV references where possible.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1171&r2=1.1172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2009/07/09 11:28:09	1.1171
+++ LVM2/WHATS_NEW	2009/07/09 11:29:00	1.1172
@@ -1,5 +1,7 @@
 Version 2.02.49 - 
 ================================
+  Fix segment metadata read function errors to use proper segment name.
+  Add parent node to config_node structure.
   Fix segment import functions to print segment name and logical volume name.
   Update vgsplit and vgcreate to call the new vg_create, then call 'set' fns.
   Change vg_create to take minimal parameters, obtain a lock, and return vg_t.
--- LVM2/lib/config/config.c	2009/03/26 09:25:18	1.73
+++ LVM2/lib/config/config.c	2009/07/09 11:29:00	1.74
@@ -546,6 +546,7 @@
 			root = n;
 		else
 			l->sib = n;
+		n->parent = root;
 		l = n;
 	}
 	return root;
@@ -573,6 +574,7 @@
 				root->child = n;
 			else
 				l->sib = n;
+			n->parent = root;
 			l = n;
 		}
 		match(TOK_SECTION_E);
@@ -1251,6 +1253,10 @@
 	return count_chars(str, len, c);
 }
 
+const char *config_parent_name(const struct config_node *n)
+{
+	return (n->parent ? n->parent->key : "(root)");
+}
 /*
  * Heuristic function to make a quick guess as to whether a text
  * region probably contains a valid config "section".  (Useful for
--- LVM2/lib/config/config.h	2008/11/03 22:14:27	1.26
+++ LVM2/lib/config/config.h	2009/07/09 11:29:00	1.27
@@ -40,7 +40,7 @@
 
 struct config_node {
 	char *key;
-	struct config_node *sib, *child;
+	struct config_node *parent, *sib, *child;
 	struct config_value *v;
 };
 
@@ -110,4 +110,6 @@
 
 unsigned maybe_config_section(const char *str, unsigned len);
 
+const char *config_parent_name(const struct config_node *n);
+
 #endif
--- LVM2/lib/mirror/mirrored.c	2009/02/28 20:04:25	1.61
+++ LVM2/lib/mirror/mirrored.c	2009/07/09 11:29:00	1.62
@@ -78,7 +78,7 @@
 {
 	if (!get_config_uint32(sn, "mirror_count", area_count)) {
 		log_error("Couldn't read 'mirror_count' for "
-			  "segment '%s'.", sn->key);
+			  "segment '%s'.", config_parent_name(sn));
 		return 0;
 	}
 
@@ -97,7 +97,8 @@
 			seg->status |= PVMOVE;
 		else {
 			log_error("Couldn't read 'extents_moved' for "
-				  "segment '%s'.", sn->key);
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
@@ -106,7 +107,8 @@
 		if (!get_config_uint32(sn, "region_size",
 				      &seg->region_size)) {
 			log_error("Couldn't read 'region_size' for "
-				  "segment '%s'.", sn->key);
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
@@ -118,22 +120,25 @@
 		}
 		logname = cn->v->v.str;
 		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
-			log_error("Unrecognised mirror log in segment %s.",
-				  sn->key);
+			log_error("Unrecognised mirror log in "
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 		seg->log_lv->status |= MIRROR_LOG;
 	}
 
 	if (logname && !seg->region_size) {
-		log_error("Missing region size for mirror log for segment "
-			  "'%s'.", sn->key);
+		log_error("Missing region size for mirror log for "
+			  "segment %s of logical volume %s.",
+			  config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
 	if (!(cn = find_config_node(sn, "mirrors"))) {
-		log_error("Couldn't find mirrors array for segment "
-			  "'%s'.", sn->key);
+		log_error("Couldn't find mirrors array for "
+			  "segment %s of logical volume %s.",
+			  config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
--- LVM2/lib/striped/striped.c	2009/02/28 20:04:25	1.27
+++ LVM2/lib/striped/striped.c	2009/07/09 11:29:01	1.28
@@ -54,7 +54,7 @@
 {
 	if (!get_config_uint32(sn, "stripe_count", area_count)) {
 		log_error("Couldn't read 'stripe_count' for "
-			  "segment '%s'.", sn->key);
+			  "segment '%s'.", config_parent_name(sn));
 		return 0;
 	}
 
@@ -68,14 +68,14 @@
 
 	if ((seg->area_count != 1) &&
 	    !get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
-		log_error("Couldn't read stripe_size for segment '%s'.",
-			  sn->key);
+		log_error("Couldn't read stripe_size for segment %s "
+			  "of logical volume %s.", config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
 	if (!(cn = find_config_node(sn, "stripes"))) {
-		log_error("Couldn't find stripes array for segment "
-			  "'%s'.", sn->key);
+		log_error("Couldn't find stripes array for segment %s "
+			  "of logical volume %s.", config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 


