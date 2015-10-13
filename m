From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:03 +0000 (UTC)
Subject: master - cleanup: more readable code
Message-ID: <20151013140403.1F8B2602BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4fb97c85082b964397a4e7930d7aa809ffd58f9
Commit:        f4fb97c85082b964397a4e7930d7aa809ffd58f9
Parent:        8b9533f38f32143e73979542161e62801438922a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:37:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:57 2015 +0200

cleanup: more readable code

---
 lib/log/log.c         |    5 +----
 lib/log/lvm-logging.h |    4 ++--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 7f31361..2f1be72 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -49,10 +49,7 @@ static size_t _lvm_errmsg_len = 0;
 
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
-	if (log_fn)
-		_lvm2_log_fn = log_fn;
-	else
-		_lvm2_log_fn = NULL;
+	_lvm2_log_fn = log_fn;
 }
 
 /*
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 983da5b..84bf3f4 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -16,9 +16,9 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
+__attribute__ ((format(printf, 5, 6)))
 void print_log(int level, const char *file, int line, int dm_errno_or_class,
-	       const char *format, ...)
-    __attribute__ ((format(printf, 5, 6)));
+	       const char *format, ...);
 
 #define LOG_LINE(l, x...) \
     print_log(l, __FILE__, __LINE__ , 0, ## x)


