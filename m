From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  2 Apr 2013 13:18:22 +0000 (UTC)
Subject: master - log: reenable abort
Message-ID: <20130402131822.5E5BEE2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2edf488b3844a067bcdfe8f8efdf1a086c52a5cf
Commit:        2edf488b3844a067bcdfe8f8efdf1a086c52a5cf
Parent:        5c93f3997b11b33742c562b39d60949bf7e6c01d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 28 13:33:20 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 2 15:16:04 2013 +0200

log: reenable abort

abort_on_internal_error got ignored with the new class logging commit.j
Put this check back in this return path, so the check is not skipped.
---
 lib/log/log.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 3b038f5..06e053f 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -346,11 +346,12 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		va_end(ap);
 	}
 
-	if (level > debug_level())
-		return;
-
-	if (level >= _LOG_DEBUG && !debug_class_is_logged(dm_errno_or_class))
+	if ((level > debug_level()) ||
+	    (level >= _LOG_DEBUG && !debug_class_is_logged(dm_errno_or_class))) {
+		if (fatal_internal_error)
+			abort();
 		return;
+	}
 
 	if (_log_to_file && (_log_while_suspended || !critical_section())) {
 		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),


