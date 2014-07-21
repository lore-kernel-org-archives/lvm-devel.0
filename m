From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 21 Jul 2014 15:02:00 +0000 (UTC)
Subject: master - metadata: Reinstate system info in metadata.
Message-ID: <20140721150200.34D1B60D23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3366baf07675a259eeb7828fb6e605108a5a4290
Commit:        3366baf07675a259eeb7828fb6e605108a5a4290
Parent:        513fd029a635470522e1c8a9cdddb70eec39474a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 21 15:54:20 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 21 15:54:20 2014 +0100

metadata: Reinstate system info in metadata.

Revert part of cac0722cacaac06ac1211194f1d6c21572a32998

This was deliberate and aids the investigation of problems.
---
 lib/format_text/export.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index aa0d905..bea97de 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -329,7 +329,6 @@ static int _print_header(struct formatter *f,
 {
 	char *buf;
 	time_t t;
-	char com[PATH_MAX];
 
 	t = time(NULL);
 
@@ -345,10 +344,9 @@ static int _print_header(struct formatter *f,
 	}
 	outf(f, "description = \"%s\"", dm_escape_double_quotes(buf, desc));
 	outnl(f);
-	(void) dm_snprintf(com, sizeof(com), "# %s %s %s %s %s",
-			   _utsname.sysname, _utsname.nodename, _utsname.release,
-			   _utsname.version, _utsname.machine);
-	outfc(f, com, "creation_host = \"%s\"", _utsname.nodename);
+	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
+	     _utsname.sysname, _utsname.nodename, _utsname.release,
+	     _utsname.version, _utsname.machine);
 	outf(f, "creation_time = %lu\t# %s", t, ctime(&t));
 
 	return 1;


