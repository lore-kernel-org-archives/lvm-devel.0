From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:55:44 +0100
Subject: [PATCH 5/6] Fix report_uint64
In-Reply-To: <cover.1265812946.git.zkabelac@redhat.com>
References: <cover.1265812946.git.zkabelac@redhat.com>
Message-ID: <8f96eac8a4e3a4ee51b852b39988ecc747ecfc8c.1265812946.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix dm_report_field_uint64 to really use 64bit.
Function is currently not used by lvm - so another fix might be,
to complete remove this function.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-report.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index aead864..e13115a 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -207,7 +207,7 @@ int dm_report_field_int32(struct dm_report *rh,
 int dm_report_field_uint64(struct dm_report *rh,
 			   struct dm_report_field *field, const uint64_t *data)
 {
-	const int value = *data;
+	const uint64_t value = *data;
 	uint64_t *sortval;
 	char *repstr;
 
@@ -221,12 +221,12 @@ int dm_report_field_uint64(struct dm_report *rh,
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, 21, "%d", value) < 0) {
-		log_error("dm_report_field_uint64: uint64 too big: %d", value);
+	if (dm_snprintf(repstr, 21, "%" PRIu64 , value) < 0) {
+		log_error("dm_report_field_uint64: uint64 too big: %" PRIu64, value);
 		return 0;
 	}
 
-	*sortval = (const uint64_t) value;
+	*sortval = value;
 	field->sort_value = sortval;
 	field->report_string = repstr;
 
-- 
1.6.6.1


