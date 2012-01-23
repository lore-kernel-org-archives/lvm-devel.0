From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2012 17:47:36 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20120123174736.18088.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-23 17:47:36

Modified files:
	libdm          : libdm-config.c 

Log message:
	add const

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/libdm/libdm-config.c	2012/01/19 15:16:39	1.20
+++ LVM2/libdm/libdm-config.c	2012/01/23 17:47:36	1.21
@@ -852,6 +852,8 @@
 
 	case DM_CFG_STRING:
 		return _str_to_bool(v->v.str, fail);
+	default:
+		;
 	}
 
 	return fail;
@@ -861,7 +863,7 @@
  * node-based lookup
  **/
 
-struct dm_config_node *dm_config_find_node(struct dm_config_node *cn,
+struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn,
 					   const char *path)
 {
 	return (struct dm_config_node *) _find_config_node(cn, path);


