From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2009 03:14:25 -0000
Subject: LVM2/libdm libdm-report.c
Message-ID: <20090110031425.8178.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-10 03:14:24

Modified files:
	libdm          : libdm-report.c 

Log message:
	Add <report_type>_all to help text.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/libdm/libdm-report.c	2009/01/10 03:01:35	1.27
+++ LVM2/libdm/libdm-report.c	2009/01/10 03:14:24	1.28
@@ -254,6 +254,11 @@
 		if (strlen(rh->fields[f].id) > id_len)
 			id_len = strlen(rh->fields[f].id);
 
+
+	for (type = rh->types; type->data_fn; type++)
+		if (strlen(type->prefix) + 3 > id_len)
+			id_len = strlen(type->prefix) + 3;
+
 	for (f = 0; rh->fields[f].report_fn; f++) {
 		if ((type = _find_type(rh, rh->fields[f].type)) && type->desc)
 			desc = type->desc;
@@ -266,6 +271,9 @@
 			log_warn("%*.*s", (int) strlen(desc) + 7,
 				 (int) strlen(desc) + 7,
 				 "-------------------------------------------------------------------------------");
+			log_warn("  %sall%-*s - %s", type->prefix,
+				 (int) (id_len - 3 - strlen(type->prefix)), "",
+				 "All fields in this section.");
 		}
 
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */


