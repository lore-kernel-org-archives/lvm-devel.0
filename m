From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:37 +0000 (UTC)
Subject: master - cleanup: use unsigned with EPOCH printf format
Message-ID: <20160505220137.B002E60C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=673d4f745322d6d9ca274697148267114058beec
Commit:        673d4f745322d6d9ca274697148267114058beec
Parent:        ed9162cd882426109fba14413ff2840edfd99341
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 3 21:24:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:55:20 2016 +0200

cleanup: use unsigned with EPOCH printf format

---
 lib/log/log.c |    2 +-
 man/lvm.8.in  |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index d939b9d..7b0026f 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -90,7 +90,7 @@ void init_log_file(const char *log_file, int append)
 			log_warn("WARNING: Cannot parse content of %s.", statfile);
 		} else {
 			if (dm_snprintf(_log_file_path, sizeof(_log_file_path),
-					"%s_%s_%d_%lld", log_file, env, pid, starttime) < 0) {
+					"%s_%s_%d_%llu", log_file, env, pid, starttime) < 0) {
 				log_warn("WARNING: Debug log file path is too long for epoch.");
 				_log_file_path[0] = '\0';
 			} else {
diff --git a/man/lvm.8.in b/man/lvm.8.in
index d2da72c..f8400cf 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -764,7 +764,8 @@ Path to the socket used to communicate with lvmpolld..
 .TP
 .B LVM_LOG_FILE_EPOCH
 A string of up to 32 letters appended to the log filename and
-followed by the process ID and a timestamp.  When set, each process logs to a
+followed by the process ID and a startup timestamp using
+this format string "_%s_%d_%llu".  When set, each process logs to a
 separate file.
 .TP
 .B LVM_EXPECTED_EXIT_STATUS


