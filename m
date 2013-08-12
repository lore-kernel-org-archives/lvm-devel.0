From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 12 Aug 2013 17:41:20 +0000 (UTC)
Subject: master - logging: tidy log_sys_error when string empty
Message-ID: <20130812174120.2525E613D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28760275e69f16d43b8cb1a31dd5b5e14ff232b6
Commit:        28760275e69f16d43b8cb1a31dd5b5e14ff232b6
Parent:        cba228f856c44415302c648770f622c3ed56ed4d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 12 18:40:41 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 12 18:40:41 2013 +0100

logging: tidy log_sys_error when string empty

---
 WHATS_NEW     |    1 +
 lib/log/log.h |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 454240f..44a1437 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Suppress arg: prefix in log_sys_error macro when arg is empty string.
   Fix bug making lvchange unable to change recovery rate for RAID.
   Prohibit conversion of thin pool to external origin.
   Workaround gcc v4.8 -O2 bug causing failures if config/checks=1 (32bit arch).
diff --git a/lib/log/log.h b/lib/log/log.h
index 064ba0a..99e7623 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -99,9 +99,9 @@
 
 /* System call equivalents */
 #define log_sys_error(x, y) \
-		log_err("%s: %s failed: %s", y, x, strerror(errno))
+		log_err("%s%s%s failed: %s", y, *y ? ": " : "", x, strerror(errno))
 #define log_sys_error_suppress(s, x, y) \
-		log_err_suppress(s, "%s: %s failed: %s", y, x, strerror(errno))
+		log_err_suppress(s, "%s%s%s failed: %s", y, *y ? ": " : "", x, strerror(errno))
 #define log_sys_very_verbose(x, y) \
 		log_info("%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_debug(x, y) \


