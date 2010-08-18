From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:51:55 -0400
Subject: [PATCH 04/11] Add macro definitions to report infrastructure for character arrays.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rather than hard code the size of the field, use a #define.
The #define will be needed in a future patch when we extend the reporting
infrastructure to have 'get' and 'set' functions for each field, allowing
lvm2app functions which query any report field.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 libdm/libdevmapper.h |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e535d2b..38b901f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1048,14 +1048,19 @@ struct dm_report_field;
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
-- 
1.7.2.1


