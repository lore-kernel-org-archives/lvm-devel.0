From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:15 +0000 (UTC)
Subject: master - metadata: use outfc for comments
Message-ID: <20140717142915.6CCF661183@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cac0722cacaac06ac1211194f1d6c21572a32998
Commit:        cac0722cacaac06ac1211194f1d6c21572a32998
Parent:        f5d6c4b0f3527b42ff3e7ef7a68010c3540d6f41
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 16 23:57:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:17:44 2014 +0200

metadata: use outfc for comments

Few unecessary comments were written to on-disc metadata.
Use outfc() to have comments only in archived files.
(may also save couple bytes in ringbuffer).

TODO: needed validation against newline char...
---
 lib/format_text/export.c |   10 ++++++----
 lib/striped/striped.c    |    4 ++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 319e5ea..aa0d905 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -329,6 +329,7 @@ static int _print_header(struct formatter *f,
 {
 	char *buf;
 	time_t t;
+	char com[PATH_MAX];
 
 	t = time(NULL);
 
@@ -344,9 +345,10 @@ static int _print_header(struct formatter *f,
 	}
 	outf(f, "description = \"%s\"", dm_escape_double_quotes(buf, desc));
 	outnl(f);
-	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
-	     _utsname.sysname, _utsname.nodename, _utsname.release,
-	     _utsname.version, _utsname.machine);
+	(void) dm_snprintf(com, sizeof(com), "# %s %s %s %s %s",
+			   _utsname.sysname, _utsname.nodename, _utsname.release,
+			   _utsname.version, _utsname.machine);
+	outfc(f, com, "creation_host = \"%s\"", _utsname.nodename);
 	outf(f, "creation_time = %lu\t# %s", t, ctime(&t));
 
 	return 1;
@@ -396,7 +398,7 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	outf(f, "seqno = %u", vg->seqno);
 
 	if (vg->fid && vg->fid->fmt)
-		outf(f, "format = \"%s\" # informational", vg->fid->fmt->name);
+		outfc(f, "# informational", "format = \"%s\"", vg->fid->fmt->name);
 
 	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 3b08467..dfd4518 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -94,8 +94,8 @@ static int _striped_text_import(struct lv_segment *seg, const struct dm_config_n
 static int _striped_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 
-	outf(f, "stripe_count = %u%s", seg->area_count,
-	     (seg->area_count == 1) ? "\t# linear" : "");
+	outfc(f, (seg->area_count == 1) ? "# linear" : NULL,
+	      "stripe_count = %u", seg->area_count);
 
 	if (seg->area_count > 1)
 		outsize(f, (uint64_t) seg->stripe_size,


