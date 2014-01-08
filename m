From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  8 Jan 2014 01:38:35 +0000 (UTC)
Subject: master - Misc: Get rid of some compiler warnings.
Message-ID: <20140108013835.631A260BD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a4efb2f1620b5875395966b66510392d1ebe60a
Commit:        3a4efb2f1620b5875395966b66510392d1ebe60a
Parent:        a832120521ea4cd528b8228bf0fe1cf80fa603e9
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jan 7 19:37:07 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jan 7 19:37:07 2014 -0600

Misc:  Get rid of some compiler warnings.

---
 daemons/cmirrord/logging.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/cmirrord/logging.h b/daemons/cmirrord/logging.h
index 40dd462..facc1b2 100644
--- a/daemons/cmirrord/logging.h
+++ b/daemons/cmirrord/logging.h
@@ -63,7 +63,7 @@ extern int log_resend_requests;
 #ifdef DEBUG
 #define LOG_DBG(f, arg...) LOG_OUTPUT(LOG_DEBUG, f, ## arg)
 #else /* DEBUG */
-#define LOG_DBG(f, arg...)
+#define LOG_DBG(f, arg...) do {} while (0)
 #endif /* DEBUG */
 
 #define LOG_COND(__X, f, arg...) do {\


