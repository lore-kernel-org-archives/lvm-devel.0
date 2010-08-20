From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 12:44:31 -0000
Subject: LVM2/libdm libdevmapper.h
Message-ID: <20100820124431.26133.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 12:44:31

Modified files:
	libdm          : libdevmapper.h 

Log message:
	Add macro definitions to report infrastructure for character array length.
	
	Rather than hard code the size of the field, use a #define, so we can re-use.
	The #define will be needed in a future patch when we extend the reporting
	infrastructure to have 'get' and 'set' functions for each field, allowing
	lvm2app functions which query any report field.  In order to provide a
	generic lookup based on the field id, we will define a type containing this
	field id, and thus, we will need to re-use the length of this string as
	it's defined inside libdevmapper.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/libdm/libdevmapper.h	2010/07/21 13:40:22	1.124
+++ LVM2/libdm/libdevmapper.h	2010/08/20 12:44:30	1.125
@@ -1048,14 +1048,19 @@
 #define DM_REPORT_FIELD_TYPE_STRING	0x00000010
 #define DM_REPORT_FIELD_TYPE_NUMBER	0x00000020
 
+#define DM_REPORT_FIELD_TYPE_ID_LEN 32
+#define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
+
 struct dm_report;
 struct dm_report_field_type {
 	uint32_t type;		/* object type id */
 	uint32_t flags;		/* DM_REPORT_FIELD_* */
 	uint32_t offset;	/* byte offset in the object */
 	int32_t width;		/* default width */
-	const char id[32];	/* string used to specify the field */
-	const char heading[32];	/* string printed in header */
+	/* string used to specify the field */
+	const char id[DM_REPORT_FIELD_TYPE_ID_LEN];
+	/* string printed in header */
+	const char heading[DM_REPORT_FIELD_TYPE_HEADING_LEN];
 	int (*report_fn)(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field, const void *data,
 			 void *private_data);


