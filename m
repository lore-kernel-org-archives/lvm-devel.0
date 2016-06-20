From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 12:22:39 +0000 (UTC)
Subject: master - cleanup: log: use hex numbers instead of decimal for _LOG_*
Message-ID: <20160620122239.1B2AB60910@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99ea03571a835c3a56b364be4ccebcc745d09dbe
Commit:        99ea03571a835c3a56b364be4ccebcc745d09dbe
Parent:        a77732c18089a12fa7c009a02cc1f1d6636a4284
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 20 14:22:31 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 14:22:31 2016 +0200

cleanup: log: use hex numbers instead of decimal for _LOG_*

---
 lib/log/log.h |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/log/log.h b/lib/log/log.h
index 15d363e..1bc9cbe 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -41,16 +41,16 @@
 
 #define EUNCLASSIFIED -1	/* Generic error code */
 
-#define _LOG_STDERR 128 /* force things to go to stderr, even if loglevel
-			   would make them go to stdout */
-#define _LOG_ONCE 256 /* downgrade to NOTICE if this has been already logged */
-#define _LOG_BYPASS_REPORT 512 /* do not log through report even if report available */
-#define _LOG_DEBUG 7
-#define _LOG_INFO 6
-#define _LOG_NOTICE 5
-#define _LOG_WARN 4
-#define _LOG_ERR 3
-#define _LOG_FATAL 2
+#define _LOG_FATAL         0x0002
+#define _LOG_ERR           0x0003
+#define _LOG_WARN          0x0004
+#define _LOG_NOTICE        0x0005
+#define _LOG_INFO          0x0006
+#define _LOG_DEBUG         0x0007
+#define _LOG_STDERR        0x0080 /* force things to go to stderr, even if loglevel would make them go to stdout */
+#define _LOG_ONCE          0x0100 /* downgrade to NOTICE if this has been already logged */
+#define _LOG_BYPASS_REPORT 0x0200 /* do not log through report even if report available */
+
 #define INTERNAL_ERROR "Internal error: "
 
 /*


