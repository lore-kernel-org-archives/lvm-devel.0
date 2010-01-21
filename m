From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jan 2010 21:04:21 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100121210421.26930.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-01-21 21:04:21

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Correct 'void *' usage in pvcreate_single.
	
	Remove needless cast.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.309&r2=1.310

--- LVM2/lib/metadata/metadata.c	2010/01/07 14:29:53	1.309
+++ LVM2/lib/metadata/metadata.c	2010/01/21 21:04:20	1.310
@@ -1348,7 +1348,7 @@
 					 const char *pv_name,
 					 struct pvcreate_params *pp)
 {
-	void *pv;
+	struct physical_volume *pv;
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
@@ -1418,8 +1418,7 @@
 
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
-	if (!(pv_write(cmd, (struct physical_volume *)pv, &mdas,
-		       pp->labelsector))) {
+	if (!(pv_write(cmd, pv, &mdas, pp->labelsector))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
 	}


