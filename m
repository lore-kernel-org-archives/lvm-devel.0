From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Jun 2014 08:52:01 +0000 (UTC)
Subject: master - cleanup: drop inline keyword
Message-ID: <20140610085201.7908160A38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e52a7788f71aa0b1235193902163f7e77f817c1
Commit:        5e52a7788f71aa0b1235193902163f7e77f817c1
Parent:        2f260c99096c9db4aa6c3d3623739d18c203e1b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 10 10:46:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 10 10:51:26 2014 +0200

cleanup: drop inline keyword

Inline would need function body in header file.
---
 lib/misc/lvm-wrappers.c |   18 ++++++------------
 lib/misc/lvm-wrappers.h |    4 ++--
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 4e3ff33..ed84bec 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -140,26 +140,20 @@ unsigned lvm_even_rand(unsigned *seed, unsigned max)
 	return ret;
 }
 
-#ifdef CLVMD_PIDFILE
-inline int clvmd_is_running(void)
+int clvmd_is_running(void)
 {
+#ifdef CLVMD_PIDFILE
 	return dm_daemon_is_running(CLVMD_PIDFILE);
-}
 #else
-inline int clvmd_is_running(void)
-{
 	return 0;
-}
 #endif
+}
 
-#ifdef CMIRRORD_PIDFILE
-inline int cmirrord_is_running(void)
+int cmirrord_is_running(void)
 {
+#ifdef CMIRRORD_PIDFILE
 	return dm_daemon_is_running(CMIRRORD_PIDFILE);
-}
 #else
-inline int cmirrord_is_running(void)
-{
 	return 0;
-}
 #endif
+}
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index fbf28b8..d147a99 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -37,8 +37,8 @@ int read_urandom(void *buf, size_t len);
  */
 unsigned lvm_even_rand(unsigned *seed, unsigned max);
 
-inline int clvmd_is_running(void);
-inline int cmirrord_is_running(void);
+int clvmd_is_running(void);
+int cmirrord_is_running(void);
 
 
 #endif


