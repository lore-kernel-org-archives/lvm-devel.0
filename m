From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:06 +0000 (UTC)
Subject: master - cleanup: report: reuse existing _uuid_disp fn to report pv_uuid field
Message-ID: <20150921124606.0769D61059@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f644431346465389bf1aaab0e9880cf0b1751c5a
Commit:        f644431346465389bf1aaab0e9880cf0b1751c5a
Parent:        83a52c07b7c7f36a084a21cce148061c1e77cd21
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 11:34:03 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 12:13:01 2015 +0200

cleanup: report: reuse existing _uuid_disp fn to report pv_uuid field

---
 lib/report/report.c |   32 +++++++++++++++-----------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 4fd311a..1c6ce5b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1271,6 +1271,18 @@ static int _chars_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 	return dm_report_field_string(rh, field, (const char * const *) &data);
 }
 
+static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+		      struct dm_report_field *field,
+		      const void *data, void *private __attribute__((unused)))
+{
+	char *repstr;
+
+	if (!(repstr = id_format_and_copy(mem, data)))
+		return_0;
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
@@ -2187,30 +2199,16 @@ static int _vglockargs_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _string_disp(rh, mem, field, &repstr, private);
 }
 
-static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
-		      struct dm_report_field *field,
-		      const void *data, void *private __attribute__((unused)))
-{
-	char *repstr;
-
-	if (!(repstr = id_format_and_copy(mem, data)))
-		return_0;
-
-	return _field_set_value(field, repstr, NULL);
-}
-
 static int _pvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 		        struct dm_report_field *field,
 		        const void *data, void *private __attribute__((unused)))
 {
 	const struct label *label = (const struct label *) data;
-	const char *repstr = "";
 
-	if (label->dev &&
-	    !(repstr = id_format_and_copy(mem, (const struct id *) label->dev->pvid)))
-		return_0;
+	if (!label->dev)
+		return _field_set_value(field, "", NULL);
 
-	return _field_set_value(field, repstr, NULL);
+	return _uuid_disp(rh, mem, field, label->dev->pvid, private);
 }
 
 static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,


