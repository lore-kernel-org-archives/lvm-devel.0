From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:39 +0000 (UTC)
Subject: master - metadata: format_text: reuse _print_timestamp fn
Message-ID: <20160303131939.7B79661B8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54d3d976c71d45748fef267b5c35a49467e781c5
Commit:        54d3d976c71d45748fef267b5c35a49467e781c5
Parent:        3a0ef77305b179511aae6d8e5af05bbbebabee6b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:21:05 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:46:39 2016 +0100

metadata: format_text: reuse _print_timestamp fn

---
 lib/format_text/export.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index f17ccf5..c4c7b38 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -675,8 +675,6 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 	struct lv_segment *seg;
 	char buffer[4096];
 	int seg_count;
-	struct tm *local_tm;
-	time_t ts;
 	uint64_t status = lv->status;
 
 	outnl(f);
@@ -705,16 +703,10 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 		return_0;
 
 	if (lv->timestamp) {
-		ts = (time_t)lv->timestamp;
-		strncpy(buffer, "# ", sizeof(buffer));
-		if (!(local_tm = localtime(&ts)) ||
-		    !strftime(buffer + 2, sizeof(buffer) - 2,
-			      "%Y-%m-%d %T %z", local_tm))
-			buffer[0] = 0;
-
+		if (!_print_timestamp(f, "creation_time", lv->timestamp,
+				      buffer, sizeof(buffer)))
+			return_0;
 		outf(f, "creation_host = \"%s\"", lv->hostname);
-		outfc(f, buffer, "creation_time = %" PRIu64,
-		      lv->timestamp);
 	}
 
 	if (lv->lock_args)


