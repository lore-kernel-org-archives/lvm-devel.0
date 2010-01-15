From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 15 Jan 2010 17:46:08 -0000
Subject: LVM2/lib/snapshot snapshot.c
Message-ID: <20100115174608.29126.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-15 17:46:08

Modified files:
	lib/snapshot   : snapshot.c 

Log message:
	Detect case of both merging_store and cow_store supplied in
	_snap_text_import().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/lib/snapshot/snapshot.c	2010/01/15 16:35:26	1.44
+++ LVM2/lib/snapshot/snapshot.c	2010/01/15 17:46:08	1.45
@@ -46,9 +46,14 @@
 
 	old_suppress = log_suppress(1);
 
-	/* FIXME Detect case of both merging_store and cow_store supplied */
-	if ((cow_name = find_config_str(sn, "merging_store", NULL)))
+	if ((cow_name = find_config_str(sn, "merging_store", NULL))) {
+		if (find_config_str(sn, "cow_store", NULL)) {
+			log_suppress(old_suppress);
+			log_error("Both snapshot cow and merging storage were specified.");
+			return 0;
+		}
 		merge = 1;
+	}
 	else if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
 		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");


