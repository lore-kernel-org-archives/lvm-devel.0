From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Mar 2008 16:20:55 -0000
Subject: LVM2 ./WHATS_NEW lib/datastruct/list.h
Message-ID: <20080326162055.7417.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-26 16:20:54

Modified files:
	.              : WHATS_NEW 
	lib/datastruct : list.h 

Log message:
	Add list_move() support function for list manipulation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.807&r2=1.808
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2008/03/25 15:24:57	1.807
+++ LVM2/WHATS_NEW	2008/03/26 16:20:54	1.808
@@ -1,6 +1,7 @@
 Version 2.02.34 -
 ===================================
-  Add 'is_reserved_lvname()' helper function.
+  Add list_move() for moving elements from one list to another.
+  Add 'is_reserved_lvname()' for identifying hidden LVs.
   Correct command name in lvmdiskscan man page.
   clvmd no longer crashes if it sees nodeids over 50.
   Fix potential deadlock in clvmd thread handling.
--- LVM2/lib/datastruct/list.h	2007/08/20 20:55:24	1.25
+++ LVM2/lib/datastruct/list.h	2008/03/26 16:20:54	1.26
@@ -55,6 +55,16 @@
 void list_del(struct list *elem);
 
 /*
+ * Move an element from an existing list to list 'head'.
+ * Insert the element before 'head'.
+ */
+static inline void list_move(struct list *item, struct list *head)
+{
+        list_del(item);
+        list_add(head, item);
+}
+
+/*
  * Is the list empty?
  */
 int list_empty(const struct list *head);


