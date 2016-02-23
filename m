From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:38 +0000 (UTC)
Subject: master - cleanup: use sizeof instead of macro.
Message-ID: <20160223204138.B615D603B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79809d6cdc3a1e4dfb4466fc0e10040bd069211d
Commit:        79809d6cdc3a1e4dfb4466fc0e10040bd069211d
Parent:        9267e0c5e73b74177fc54dda200f012765b33673
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 20:19:50 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:17 2016 +0100

cleanup: use sizeof instead of macro.

Keep the buffer size defined at a single place and then use
its sizeof.
---
 libdm/libdm-report.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0163910..8250a35 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -889,7 +889,7 @@ static void _all_match_combine(const struct dm_report_object_type *types,
 	const struct dm_report_object_type *t;
 	size_t prefix_len;
 
-	if (!_get_canonical_field_name(field, flen, field_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
+	if (!_get_canonical_field_name(field, flen, field_canon, sizeof(field_canon), NULL))
 		return;
 	flen = strlen(field_canon);
 
@@ -949,7 +949,7 @@ static int _get_field(struct dm_report *rh, const char *field, size_t flen,
 	if (!flen)
 		return 0;
 
-	if (!_get_canonical_field_name(field, flen, field_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
+	if (!_get_canonical_field_name(field, flen, field_canon, sizeof(field_canon), NULL))
 		return_0;
 
 	for (f = 0; _implicit_report_fields[f].report_fn; f++) {
@@ -1063,7 +1063,7 @@ static int _key_match(struct dm_report *rh, const char *key, size_t len,
 		return 0;
 	}
 
-	if (!_get_canonical_field_name(key, len, key_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
+	if (!_get_canonical_field_name(key, len, key_canon, sizeof(key_canon), NULL))
 		return_0;
 
 	for (f = 0; _implicit_report_fields[f].report_fn; f++)
@@ -1196,7 +1196,7 @@ static int _canonicalize_field_ids(struct dm_report *rh)
 
 	for (i = 0; i < registered_field_count; i++) {
 		if (!_get_canonical_field_name(rh->fields[i].id, strlen(rh->fields[i].id),
-					       canonical_field, DM_REPORT_FIELD_TYPE_ID_LEN, &differs))
+					       canonical_field, sizeof(canonical_field), &differs))
 			return_0;
 
 		if (differs) {


