From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 11:21:17 +0000 (UTC)
Subject: master - cleanup: add stack traces
Message-ID: <20151119112117.3EFBC60E43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b2be6049730e8dbab3d715633e967b4b2992f78
Commit:        0b2be6049730e8dbab3d715633e967b4b2992f78
Parent:        e2b00b0a899376b3336e146dc3f4c077726d938a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 18 09:15:45 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 18 22:17:26 2015 +0100

cleanup: add stack traces

---
 libdm/libdm-report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 8ca0dc0..27044c0 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -949,7 +949,7 @@ static int _get_field(struct dm_report *rh, const char *field, size_t flen,
 		return 0;
 
 	if (!_get_canonical_field_name(field, flen, field_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
-		return 0;
+		return_0;
 
 	for (f = 0; _implicit_report_fields[f].report_fn; f++) {
 		if (_is_same_field(_implicit_report_fields[f].id, field_canon, rh->field_prefix)) {
@@ -1063,7 +1063,7 @@ static int _key_match(struct dm_report *rh, const char *key, size_t len,
 	}
 
 	if (!_get_canonical_field_name(key, len, key_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
-		return 0;
+		return_0;
 
 	for (f = 0; _implicit_report_fields[f].report_fn; f++)
 		if (_is_same_field(_implicit_report_fields[f].id, key_canon, rh->field_prefix))


