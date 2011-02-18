From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:34:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c lib/for ...
Message-ID: <20110218143447.15849.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:34:42

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 
	lib/format_text: text_label.c 

Log message:
	Void* arithmetic replaced with char*

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1918&r2=1.1919
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2011/02/18 14:29:39	1.1918
+++ LVM2/WHATS_NEW	2011/02/18 14:34:41	1.1919
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Use char* arithmetic in _text_write(), _text_read() & send_message().
   Fix compilation when devmapper is dissabled.
   Remove fs_unlock() from lv_suspend error path.
   Change memory locking semantic and use critical sections.
--- LVM2/daemons/clvmd/clvmd.c	2011/01/17 23:13:14	1.93
+++ LVM2/daemons/clvmd/clvmd.c	2011/02/18 14:34:41	1.94
@@ -1867,7 +1867,7 @@
 				break;
 			}
 
-			len = write(fd, buf + ptr, msglen - ptr);
+			len = write(fd, (char*)buf + ptr, msglen - ptr);
 
 			if (len <= 0) {
 				if (errno == EINTR)
--- LVM2/lib/format_text/text_label.c	2010/10/05 17:34:06	1.38
+++ LVM2/lib/format_text/text_label.c	2011/02/18 14:34:41	1.39
@@ -52,7 +52,7 @@
 
 	strncpy((char *)lh->type, label->type, sizeof(label->type));
 
-	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;
 	pvhdr->device_size_xl = xlate64(info->device_size);
 	memcpy(pvhdr->pv_uuid, &info->dev->pvid, sizeof(struct id));
@@ -266,7 +266,7 @@
 	char *creation_host;
 	struct mda_header *mdah;
 
-	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
 				  FMT_TEXT_ORPHAN_VG_NAME,


