From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:54 +0100
Subject: [PATCH 08/16] API change - support more const arg
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <c85cf3c87f8385d14355b344ad9783981ebc18a4.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As dm_report_field_string doesn't modify content of data pointer,
it could be also marked as const.

It's slight API change - but doesn't require any change on user side
and supports wide range of arguments without const casting.
(i.e. we may use as paramater const lv struct this way:  &lv->name)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h |    2 +-
 libdm/libdm-report.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e3528d3..d7936bf 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1123,7 +1123,7 @@ int dm_report_set_output_field_name_prefix(struct dm_report *rh,
  * They take care of allocating copies of the data.
  */
 int dm_report_field_string(struct dm_report *rh, struct dm_report_field *field,
-			   const char **data);
+			   const char *const *data);
 int dm_report_field_int32(struct dm_report *rh, struct dm_report_field *field,
 			  const int32_t *data);
 int dm_report_field_uint32(struct dm_report *rh, struct dm_report_field *field,
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 4f47c46..0212284 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -102,7 +102,7 @@ static const struct dm_report_object_type *_find_type(struct dm_report *rh,
  */
 
 int dm_report_field_string(struct dm_report *rh,
-			   struct dm_report_field *field, const char **data)
+			   struct dm_report_field *field, const char *const *data)
 {
 	char *repstr;
 
-- 
1.7.4


