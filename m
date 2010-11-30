From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:53:38 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20101130225338.14835.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:53:38

Modified files:
	tools          : dmsetup.c 

Log message:
	Test uuid for NULL
	
	Add test for NULL before passing uuid as src argument to memcpy.
	As memcpy function is declared as function not accepting NULL.
	Though we pass NULL only with zero length so this patch presents
	no functional change to the code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/tools/dmsetup.c	2010/11/24 09:43:18	1.148
+++ LVM2/tools/dmsetup.c	2010/11/30 22:53:37	1.149
@@ -343,7 +343,9 @@
 		return NULL;
 	}
 
-	memcpy(uuid_prefix, uuid, len);
+	if (uuid)
+		memcpy(uuid_prefix, uuid, len);
+
 	uuid_prefix[len] = '\0';
 
 	return uuid_prefix;


