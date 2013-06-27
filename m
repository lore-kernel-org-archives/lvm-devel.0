From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 27 Jun 2013 14:09:50 +0000 (UTC)
Subject: master - metadata: log_debug only when BA found in metadata
Message-ID: <20130627140950.60C6D60C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ca168813437375d8dc96326b0d74f97f3866b5e
Commit:        0ca168813437375d8dc96326b0d74f97f3866b5e
Parent:        6de45db5b53636afff1e7e0a5d5efd012c1b7f20
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 27 16:03:35 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 27 16:03:35 2013 +0200

metadata: log_debug only when BA found in metadata

...not the other way round as it was before. This way it makes
more sense as BA use is exceptional and it's useless to
contaminate the log with messages about BA not being found
in metadata.
---
 lib/format_text/import_vsn1.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 852f2c5..99dd52a 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -246,19 +246,20 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
-	/* Bootloader area is not compulsory - just log_debug if not found. */
+	/* Bootloader area is not compulsory - just log_debug for the record if found. */
 	ba_start = size = 0;
-	if (!_read_uint64(pvn, "ba_start", &ba_start))
-		log_debug("PV Bootloader Area start value (ba_start) not found.");
-	if (!_read_uint64(pvn, "ba_size", &size))
-		log_debug("PV Bootloader Area size (ba_size) not found.");
-	if ((!ba_start && size) || (ba_start && !size)) {
-		log_error("Incomplete bootloader area specification for "
-			  "physical volume.");
-		return 0;
-	} else {
+	_read_uint64(pvn, "ba_start", &ba_start);
+	_read_uint64(pvn, "ba_size", &size);
+	if (ba_start && size) {
+		log_debug("Found bootloader area specification for PV %s "
+			  "in metadata: ba_start=%" PRIu64 ", ba_size=%" PRIu64 ".",
+			  pv_dev_name(pv), ba_start, size);
 		pv->ba_start = ba_start;
 		pv->ba_size = size;
+	} else if ((!ba_start && size) || (ba_start && !size)) {
+		log_error("Found incomplete bootloader area specification "
+			  "for PV %s in metadata.", pv_dev_name(pv));
+		return 0;
 	}
 
 	dm_list_init(&pv->tags);


