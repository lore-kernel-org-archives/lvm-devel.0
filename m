From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:19 +0000 (GMT)
Subject: master - gcc: drop bogus ;
Message-ID: <20200828195919.E2CA33842439@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b722ce2f1000da1ed321d43ef4858d1dd5d567d8
Commit:        b722ce2f1000da1ed321d43ef4858d1dd5d567d8
Parent:        19e9c88faf10bf2f9a2dd7da695b776163fb7bd4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 21:14:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:03 2020 +0200

gcc: drop bogus ;

---
 lib/metadata/metadata.c |  2 +-
 lib/report/report.c     | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4777d7923..bf3669b10 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1945,7 +1945,7 @@ static int _lv_postorder_level(struct logical_volume *lv, void *data)
 {
 	struct _lv_postorder_baton *baton = data;
 	return (data) ? _lv_postorder_visit(lv, baton->fn, baton->data) : 0;
-};
+}
 
 static int _lv_postorder_visit(struct logical_volume *lv,
 			       int (*fn)(struct logical_volume *lv, void *data),
diff --git a/lib/report/report.c b/lib/report/report.c
index 979cbee52..b0d514202 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -348,39 +348,39 @@ struct time_info {
 static int _is_time_num(time_id_t id)
 {
 	return ((id > TIME_NUM__START) && (id < TIME_NUM__END));
-};
+}
 
 /*
 static int _is_time_frame(time_id_t id)
 {
 	return ((id > TIME_FRAME__START) && (id < TIME_FRAME__END));
-};
+}
 */
 
 static int _is_time_label_date(time_id_t id)
 {
 	return ((id > TIME_LABEL_DATE__START) && (id < TIME_LABEL_DATE__END));
-};
+}
 
 static int _is_time_label_time(time_id_t id)
 {
 	return ((id > TIME_LABEL_TIME__START) && (id < TIME_LABEL_TIME__END));
-};
+}
 
 static int _is_time_unit(time_id_t id)
 {
 	return ((id > TIME_UNIT__START) && (id < TIME_UNIT__END));
-};
+}
 
 static int _is_time_weekday(time_id_t id)
 {
 	return ((id > TIME_WEEKDAY__START) && (id < TIME_WEEKDAY__END));
-};
+}
 
 static int _is_time_month(time_id_t id)
 {
 	return ((id > TIME_MONTH__START) && (id < TIME_MONTH__END));
-};
+}
 
 static const char *_skip_space(const char *s)
 {


