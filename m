From: Petr Rockai <prockai@redhat.com>
Date: Mon, 15 Dec 2014 23:32:37 +0100
Subject: [PATCH 1/4] report: Print NULL strings as "" in _string_disp (instead of a SEGV).
Message-ID: <1418682760-16427-1-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/report/report.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/report/report.c b/lib/report/report.c
index 5637d50..043de88 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -179,6 +179,8 @@ static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
+	if (!*(void**) data)
+		return _field_set_value(field, "", NULL);
 	return dm_report_field_string(rh, field, (const char * const *) data);
 }
 
-- 
2.1.2


