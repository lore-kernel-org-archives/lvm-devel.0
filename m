From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:04:18 -0000
Subject: LVM2/libdm libdevmapper.h
Message-ID: <20111028200418.22071.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:04:18

Modified files:
	libdm          : libdevmapper.h 

Log message:
	Update header comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/libdm/libdevmapper.h	2011/10/20 10:33:30	1.164
+++ LVM2/libdm/libdevmapper.h	2011/10/28 20:04:17	1.165
@@ -905,7 +905,7 @@
 void dm_list_move(struct dm_list *head, struct dm_list *elem);
 
 /*
- * Join 'head1' to the of 'head'.
+ * Join 'head1' to the end of 'head'.
  */
 void dm_list_splice(struct dm_list *head, struct dm_list *head1);
 


