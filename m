From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 May 2010 10:10:18 -0000
Subject: LVM2 ./WHATS_NEW libdm/.exported_symbols libdm ...
Message-ID: <20100506101018.20135.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-06 10:10:16

Modified files:
	.              : WHATS_NEW 
	libdm          : .exported_symbols libdevmapper.h 
	libdm/datastruct: list.c 

Log message:
	Add dm_list_splice() to join two lists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1547&r2=1.1548
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/list.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2010/05/05 22:38:31	1.1547
+++ LVM2/WHATS_NEW	2010/05/06 10:10:15	1.1548
@@ -1,6 +1,8 @@
 Version 2.02.65 - 
 =================================
   Suppress duplicate error messages about read failures and missing devices.
+  Install plugins to $(libdir)/device-mapper and $(libdir)/lvm2.
+  Add dm_list_splice() function to join two lists together.
 
 Version 2.02.64 - 30th April 2010
 =================================
--- LVM2/libdm/.exported_symbols	2010/04/20 13:58:22	1.51
+++ LVM2/libdm/.exported_symbols	2010/05/06 10:10:16	1.52
@@ -155,6 +155,7 @@
 dm_list_add_h
 dm_list_del
 dm_list_move
+dm_list_splice
 dm_list_empty
 dm_list_start
 dm_list_end
--- LVM2/libdm/libdevmapper.h	2010/04/28 13:37:36	1.112
+++ LVM2/libdm/libdevmapper.h	2010/05/06 10:10:16	1.113
@@ -718,6 +718,11 @@
 void dm_list_move(struct dm_list *head, struct dm_list *elem);
 
 /*
+ * Join 'head1' to the of 'head'.
+ */
+void dm_list_splice(struct dm_list *head, struct dm_list *head1);
+
+/*
  * Is the list empty?
  */
 int dm_list_empty(const struct dm_list *head);
--- LVM2/libdm/datastruct/list.c	2008/11/04 15:07:45	1.6
+++ LVM2/libdm/datastruct/list.c	2010/05/06 10:10:16	1.7
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -144,3 +144,25 @@
 
 	return s;
 }
+
+/*
+ * Join two lists together.
+ * This moves all the elements of the list 'head1' to the end of the list
+ * 'head', leaving 'head1' empty.
+ */
+void dm_list_splice(struct dm_list *head, struct dm_list *head1)
+{
+	assert(head->n);
+	assert(head1->n);
+
+	if (dm_list_empty(head1))
+	    return;
+
+	head1->p->n = head;
+	head1->n->p = head->p;
+
+	head->p->n = head1->n;
+	head->p = head1->p;
+
+	dm_list_init(head1);
+}


