From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:07:38 -0000
Subject: LVM2 libdm/libdm-config.c test/t-000-basic.sh
Message-ID: <20111028200738.23981.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:07:38

Modified files:
	libdm          : libdm-config.c 
	test           : t-000-basic.sh 

Log message:
	Fix core on buggy config file
	
	Since fixed within unreleased version so no WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/libdm/libdm-config.c	2011/10/28 20:06:50	1.14
+++ LVM2/libdm/libdm-config.c	2011/10/28 20:07:38	1.15
@@ -170,8 +170,12 @@
  */
 struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft)
 {
-	struct dm_config_tree *second_cft = cft->cascade;
+	struct dm_config_tree *second_cft;
 
+	if (!cft)
+		return NULL;
+
+	second_cft = cft->cascade;
 	cft->cascade = NULL;
 
 	return second_cft;
--- LVM2/test/t-000-basic.sh	2011/09/24 20:54:35	1.12
+++ LVM2/test/t-000-basic.sh	2011/10/28 20:07:38	1.13
@@ -23,3 +23,6 @@
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 5
 
+# ensure we do not crash on a bug in config file
+aux lvmconf 'log/prefix = 1""'
+not lvs


