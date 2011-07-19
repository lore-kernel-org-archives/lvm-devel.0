From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Jul 2011 19:12:38 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20110719191238.11096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-19 19:12:38

Modified files:
	lib/config     : config.c 

Log message:
	Make it possible to represent type-correct single-item arrays in config trees.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/lib/config/config.c	2011/07/19 19:11:24	1.99
+++ LVM2/lib/config/config.c	2011/07/19 19:12:38	1.100
@@ -486,11 +486,11 @@
 			line_append("=");
 			if (v->next) {
 				line_append("[");
-				while (v) {
+				while (v && v->type != CFG_EMPTY_ARRAY) {
 					if (!_write_value(outline, v))
 						return_0;
 					v = v->next;
-					if (v)
+					if (v && v->type != CFG_EMPTY_ARRAY)
 						line_append(", ");
 				}
 				line_append("]");


