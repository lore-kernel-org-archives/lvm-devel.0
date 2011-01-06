From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Jan 2011 15:25:07 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20110106152507.7370.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-06 15:25:07

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Intentionaly ignore result from get_config_uint32

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/lib/format_text/import_vsn1.c	2010/12/22 15:44:09	1.80
+++ LVM2/lib/format_text/import_vsn1.c	2011/01/06 15:25:07	1.81
@@ -840,7 +840,7 @@
 	log_suppress(old_suppress);
 	*desc = dm_pool_strdup(mem, d);
 
-	get_config_uint32(cft->root, "creation_time", &u);
+	(void) get_config_uint32(cft->root, "creation_time", &u);
 	*when = u;
 }
 


