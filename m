From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2009 00:45:35 -0000
Subject: LVM2/libdm/datastruct hash.c
Message-ID: <20091103004535.1307.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-03 00:45:35

Modified files:
	libdm/datastruct: hash.c 

Log message:
	Fix hash lookup segfault when keys compared are different lengths.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/hash.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/libdm/datastruct/hash.c	2008/11/03 18:59:59	1.9
+++ LVM2/libdm/datastruct/hash.c	2009/11/03 00:45:35	1.10
@@ -143,9 +143,13 @@
 	unsigned h = _hash(key, len) & (t->num_slots - 1);
 	struct dm_hash_node **c;
 
-	for (c = &t->slots[h]; *c; c = &((*c)->next))
+	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen != len)
+			continue;
+
 		if (!memcmp(key, (*c)->key, len))
 			break;
+	}
 
 	return c;
 }


