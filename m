From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Jun 2015 14:33:47 +0000 (UTC)
Subject: master - log: flush stdout before print to stderr
Message-ID: <20150619143347.A5F9660DEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00d028fd7739ea1f4a49f1f3df6ce1dfb7188fe0
Commit:        00d028fd7739ea1f4a49f1f3df6ce1dfb7188fe0
Parent:        3173442984dd8d31e43cb50db385f31c75cc9839
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 19 16:24:32 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 19 16:33:20 2015 +0200

log: flush stdout before print to stderr

Keep logging readable and fflush stdout before printing to stderr.
---
 lib/log/log.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index d8d65ee..20ca293 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -385,6 +385,8 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		default:
 			/* Typically only log_warn goes to stdout */
 			stream = (use_stderr || (level != _LOG_WARN)) ? stderr : stdout;
+			if (stream == stderr)
+				fflush(stdout);
 			fprintf(stream, "%s%s%s%s", buf, log_command_name(),
 				_msg_prefix, indent_spaces);
 			vfprintf(stream, trformat, ap);


