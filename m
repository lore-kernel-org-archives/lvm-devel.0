From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 07:05:01 +0000 (UTC)
Subject: master - report: also recognize variants without underscores for <prefix>_all fields
Message-ID: <20150804070501.E22EA60D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ac5689ce4d4f86c4b3985d73a0fdb4af04c298d
Commit:        6ac5689ce4d4f86c4b3985d73a0fdb4af04c298d
Parent:        d11f8d42287025ff8584b9d6f1d5e70a0d78371b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 09:03:31 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 09:03:31 2015 +0200

report: also recognize variants without underscores for <prefix>_all fields

For example: "pvs -o pv_all" and pvs -o pvall" are same.
---
 libdm/libdm-report.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 5b94311..225da90 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -876,15 +876,20 @@ static void _all_match_combine(const struct dm_report_object_type *types,
 			       const char *field, size_t flen,
 			       uint32_t *report_types)
 {
+	char field_canon[DM_REPORT_FIELD_TYPE_ID_LEN];
 	const struct dm_report_object_type *t;
 	size_t prefix_len;
 
+	if (!_get_canonical_field_name(field, flen, field_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
+		return;
+	flen = strlen(field_canon);
+
 	for (t = types; t->data_fn; t++) {
-		prefix_len = strlen(t->prefix);
+		prefix_len = strlen(t->prefix) - 1;
 
-		if (!strncasecmp(t->prefix, field, prefix_len) &&
+		if (!strncasecmp(t->prefix, field_canon, prefix_len) &&
 		    ((unprefixed_all_matched && (flen == prefix_len)) ||
-		     (!strncasecmp(field + prefix_len, "all", 3) &&
+		     (!strncasecmp(field_canon + prefix_len, "all", 3) &&
 		      (flen == prefix_len + 3))))
 			*report_types |= t->id;
 	}


