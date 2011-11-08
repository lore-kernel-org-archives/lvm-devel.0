From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 8 Nov 2011 19:02:21 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20111108190221.22587.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-11-08 19:02:21

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add missing free() for line that is malloc()'d by getline().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/libdm/ioctl/libdm-iface.c	2011/11/08 17:32:11	1.127
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/11/08 19:02:21	1.128
@@ -172,7 +172,7 @@
 {
 	FILE *fl;
 	char nm[256];
-	char *line;
+	char *line = NULL;
 	size_t len;
 	uint32_t num;
 
@@ -188,6 +188,7 @@
 					*number = num;
 					if (fclose(fl))
 						log_sys_error("fclose", file);
+					free(line);
 					return 1;
 				}
 				dm_bit_set(_dm_bitset, num);
@@ -196,6 +197,7 @@
 	}
 	if (fclose(fl))
 		log_sys_error("fclose", file);
+	free(line);
 
 	if (number) {
 		log_error("%s: No entry for %s found", file, name);


