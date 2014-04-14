From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:24 +0000 (UTC)
Subject: master - cleanup: clvmd drop unused enum state
Message-ID: <20140414110624.8E53F60CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d896abc705d8aedd1d74c6fc01985fc88e7e44ed
Commit:        d896abc705d8aedd1d74c6fc01985fc88e7e44ed
Parent:        e2f194952a218562b198c47e78f7337572cfb29e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 9 08:11:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:02:27 2014 +0200

cleanup: clvmd drop unused enum state

---
 daemons/clvmd/clvmd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index 5ecf582..f11c033 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -56,7 +56,7 @@ struct localsock_bits {
 	int cleanup_needed;     /* helper for cleanup_zombie */
 	struct local_client *pipe_client;
 	pthread_t threadid;
-	enum { PRE_COMMAND, POST_COMMAND, QUIT } state;
+	enum { PRE_COMMAND, POST_COMMAND } state;
 	pthread_mutex_t mutex;	/* Main thread and worker synchronisation */
 	pthread_cond_t cond;
 };


