From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 17:46:48 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20120228174648.2626.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 17:46:47

Modified files:
	libdm          : libdm-config.c 

Log message:
	Fix empty string warning logic in _find_config_str. (1.02.68)
	
	pvcreate gives
	WARNING: Ignoring unsupported value for metadata/pvmetadataignore.
	
	It was warning if there is no config file entry instead of only if the node
	exists but is empty.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/libdm/libdm-config.c	2012/01/23 17:47:36	1.21
+++ LVM2/libdm/libdm-config.c	2012/02/28 17:46:47	1.22
@@ -751,14 +751,16 @@
 {
 	const struct dm_config_node *n = find_fn(start, path);
 
-	/* Empty strings are ignored */
-	if ((n && n->v && n->v->type == DM_CFG_STRING) &&
-	    (allow_empty || (*n->v->v.str))) {
-		log_very_verbose("Setting %s to %s", path, n->v->v.str);
-		return n->v->v.str;
-	} else if (n && (!n->v || (n->v->type != DM_CFG_STRING) ||
-			 (!allow_empty && fail)))
-		log_warn("WARNING: Ignoring unsupported value for %s.", path);
+	/* Empty strings are ignored if allow_empty is set */
+	if (n && n->v) {
+		if ((n->v->type == DM_CFG_STRING) &&
+		    (allow_empty || (*n->v->v.str))) {
+			log_very_verbose("Setting %s to %s", path, n->v->v.str);
+			return n->v->v.str;
+		}
+		if ((n->v->type != DM_CFG_STRING) || (!allow_empty && fail))
+			log_warn("WARNING: Ignoring unsupported value for %s.", path);
+	}
 
 	if (fail)
 		log_very_verbose("%s not found in config: defaulting to %s",


