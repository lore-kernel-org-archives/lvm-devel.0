From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 8 Nov 2011 17:32:12 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20111108173212.25065.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-11-08 17:32:11

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
	
	Fixes issue reported here: http://lkml.org/lkml/2011/11/8/190

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.520&r2=1.521
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/WHATS_NEW_DM	2011/10/31 12:22:49	1.520
+++ LVM2/WHATS_NEW_DM	2011/11/08 17:32:10	1.521
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
   Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
   Add dm_config_tree_find_str_allow_empty.
   Fix compile-time pool memory locking with DEBUG_MEM.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/10/20 10:38:04	1.126
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/11/08 17:32:11	1.127
@@ -172,7 +172,8 @@
 {
 	FILE *fl;
 	char nm[256];
-	int c;
+	char *line;
+	size_t len;
 	uint32_t num;
 
 	if (!(fl = fopen(file, "r"))) {
@@ -180,8 +181,8 @@
 		return 0;
 	}
 
-	while (!feof(fl)) {
-		if (fscanf(fl, "%d %255s\n", &num, &nm[0]) == 2) {
+	while (getline(&line, &len, fl) != -1) {
+		if (sscanf(line, "%d %255s\n", &num, &nm[0]) == 2) {
 			if (!strcmp(name, nm)) {
 				if (number) {
 					*number = num;
@@ -191,9 +192,7 @@
 				}
 				dm_bit_set(_dm_bitset, num);
 			}
-		} else do {
-			c = fgetc(fl);
-		} while (c != EOF && c != '\n');
+		}
 	}
 	if (fclose(fl))
 		log_sys_error("fclose", file);


