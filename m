From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:17:15 +0000 (UTC)
Subject: master - cleanup: drop unwanted ';'
Message-ID: <20130421211715.4DC3316CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cdcde494f2824dbf8e549638331ab65b1f56b3a
Commit:        9cdcde494f2824dbf8e549638331ab65b1f56b3a
Parent:        5a751ad703c8082aaf96c53fc1e76bd8fc607235
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 22:32:43 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:15:07 2013 +0200

cleanup: drop unwanted ';'

---
 daemons/clvmd/clvmd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index 67ea41e..fb0589d 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -95,7 +95,7 @@ struct local_client {
 	} bits;
 };
 
-#define DEBUGLOG(fmt, args...) debuglog(fmt, ## args);
+#define DEBUGLOG(fmt, args...) debuglog(fmt, ## args)
 
 #ifndef max
 #define max(a,b) ((a)>(b)?(a):(b))


