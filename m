From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Sep 2010 10:42:03 -0000
Subject: LVM2/lib/format_text tags.c
Message-ID: <20100921104203.30536.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-21 10:42:03

Modified files:
	lib/format_text: tags.c 

Log message:
	"goto_bad" should be used in alloc_printed_tags function, not "goto bad".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/format_text/tags.c	2010/09/20 14:23:20	1.8
+++ LVM2/lib/format_text/tags.c	2010/09/21 10:42:02	1.9
@@ -38,21 +38,21 @@
 	}
 
 	if (!emit_to_buffer(&buf, &size, "["))
-		goto bad;
+		goto_bad;
 
 	dm_list_iterate_items(sl, tags) {
 		if (!first) {
 			if (!emit_to_buffer(&buf, &size, ", "))
-				goto bad;
+				goto_bad;
 		} else
 			first = 0;
 
 		if (!emit_to_buffer(&buf, &size, "\"%s\"", sl->str))
-			goto bad;
+			goto_bad;
 	}
 
 	if (!emit_to_buffer(&buf, &size, "]"))
-		goto bad;
+		goto_bad;
 
 	return buffer;
 


