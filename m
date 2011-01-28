From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 10:19:00 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20110128101900.1452.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 10:19:00

Modified files:
	lib/config     : config.c 

Log message:
	Use memcpy and add error message
	
	strncpy (which check each byte for \0) is not need as we always copy
	the length size - so using memcpy is a bit cheaper.
	
	Add missing log_error message for failed allocation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/lib/config/config.c	2010/12/20 13:53:11	1.87
+++ LVM2/lib/config/config.c	2011/01/28 10:19:00	1.88
@@ -886,9 +886,11 @@
 {
 	size_t len = p->te - p->tb;
 	char *str = dm_pool_alloc(p->mem, len + 1);
-	if (!str)
-		return_0;
-	strncpy(str, p->tb, len);
+	if (!str) {
+		log_error("Failed to duplicate token.");
+		return 0;
+	}
+	memcpy(str, p->tb, len);
 	str[len] = '\0';
 	return str;
 }


