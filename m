From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:45:44 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20120223224544.12279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:45:43

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-string.c 

Log message:
	Introduce dm_strncpy
	
	Should be faster then strncpy - since we could avoid clearing 4KB pages
	with each strncpy(...,PATH_MAX).
	Also it's easy to check whether string fit - and eventually avoid
	to continue working we incomplete string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.573&r2=1.574
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW_DM	2012/02/23 18:26:28	1.573
+++ LVM2/WHATS_NEW_DM	2012/02/23 22:45:43	1.574
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Add dm_strncpy() function as a faster strncpy() replacement.
 
 Version 1.02.72 - 23rd February 2012
 ====================================
--- LVM2/libdm/libdevmapper.h	2012/02/15 12:23:16	1.183
+++ LVM2/libdm/libdevmapper.h	2012/02/23 22:45:43	1.184
@@ -1211,6 +1211,15 @@
 				     char **substr_first_unquoted_colon,
 				     char **substr_first_unquoted_at_sign);
 
+/*
+ * Replacement for strncpy() function.
+ *
+ * Copies no more than n bytes from string pointed by src to the buffer
+ * pointed by dest and ensure string is finished with '\0'.
+ * Returns 0 if the whole string does not fit.
+ */
+int dm_strncpy(char *dest, const char *src, size_t n);
+
 /**************************
  * file/stream manipulation
  **************************/
--- LVM2/libdm/libdm-string.c	2012/02/23 18:19:32	1.20
+++ LVM2/libdm/libdm-string.c	2012/02/23 22:45:43	1.21
@@ -410,3 +410,13 @@
 		*substr_first_unquoted_at_sign = arr_substr_first_unquoted[1];
 }
 
+int dm_strncpy(char *dest, const char *src, size_t n)
+{
+	if (memccpy(dest, src, 0, n))
+		return 1;
+
+	if (n > 0)
+		dest[n - 1] = '\0';
+
+	return 0;
+}


