From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Sep 2009 19:06:06 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090925190606.20728.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-25 19:06:05

Modified files:
	libdm          : libdm-common.c 

Log message:
	missing dm_snprintf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/libdm/libdm-common.c	2009/09/25 18:19:09	1.84
+++ LVM2/libdm/libdm-common.c	2009/09/25 19:06:05	1.85
@@ -261,7 +261,11 @@
 		 * under /dev/mapper, use that name directly.  Otherwise call
 		 * _find_dm_name_of_device() to scan _dm_dir for a match.
 		 */
-		snprintf(path, sizeof(path), "%s/%s", _dm_dir, pos + 1);
+		if (dm_snprintf(path, sizeof(path), "%s/%s", _dm_dir,
+				pos + 1) == -1) {
+			log_error("Couldn't create path for %s", pos + 1);
+			return 0;
+		}
 
 		if (!stat(path, &st2) && (st1.st_rdev == st2.st_rdev))
 			name = pos + 1;


