From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jun 2011 19:49:41 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20110612194941.19243.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-12 19:49:41

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Fix 'pvs -o pv_all' to include label fields.  (Also removed recursion.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.470&r2=1.471
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW_DM	2011/06/11 00:03:06	1.470
+++ LVM2/WHATS_NEW_DM	2011/06/12 19:49:40	1.471
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Fix "all" report field prefix matching to include label fields with pv_all.
   Delay resuming new preloaded mirror devices with core logs in deptree code.
   Accept new kernel version 3 uname formats in initialisation.
 
--- LVM2/libdm/libdm-report.c	2011/04/08 14:40:20	1.44
+++ LVM2/libdm/libdm-report.c	2011/06/12 19:49:41	1.45
@@ -367,33 +367,32 @@
 {
 	size_t prefix_len;
 	const struct dm_report_object_type *t;
-	char prefixed_all[32];
+	uint32_t report_types = 0;
+	unsigned unprefixed_all_matched = 0;
 
 	if (!strncasecmp(field, "all", 3) && flen == 3) {
-		if (strlen(rh->field_prefix)) {
-			strcpy(prefixed_all, rh->field_prefix);
-			strcat(prefixed_all, "all");
-			/*
-			 * Add also prefix to receive all attributes
-			 * (e.g.LABEL/PVS use the same prefix)
-			 */
-			return rh->report_types |
-			       _all_match(rh, prefixed_all,
-					  strlen(prefixed_all));
-		} else
-			return (rh->report_types)
-				? rh->report_types : REPORT_TYPES_ALL;
+		/* If there's no report prefix, match all report types */
+		if (!(flen = strlen(rh->field_prefix)))
+			return rh->report_types ? : REPORT_TYPES_ALL;
+
+		/* otherwise include all fields beginning with the report prefix. */
+		unprefixed_all_matched = 1;
+		field = rh->field_prefix;
+		report_types = rh->report_types;
 	}
 
+	/* Combine all report types that have a matching prefix. */
 	for (t = rh->types; t->data_fn; t++) {
 		prefix_len = strlen(t->prefix);
+
 		if (!strncasecmp(t->prefix, field, prefix_len) &&
-		    !strncasecmp(field + prefix_len, "all", 3) &&
-		    flen == prefix_len + 3)
-			return t->id;
+		    ((unprefixed_all_matched && (flen == prefix_len)) ||
+		     (!strncasecmp(field + prefix_len, "all", 3) &&
+		      (flen == prefix_len + 3))))
+			report_types |= t->id;
 	}
 
-	return 0;
+	return report_types;
 }
 
 /*


