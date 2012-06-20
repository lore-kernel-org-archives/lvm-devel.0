From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jun 2012 12:49:08 +0000 (UTC)
Subject: master - cmirrord: add test for closedir() and close()
Message-ID: <20120620124908.842811684@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb4584b83ddfe645ac1b8c16385e9a4632171d96
Commit:        fb4584b83ddfe645ac1b8c16385e9a4632171d96
Parent:        e77803edc95d9b40e367bc447ad316bb5f9d9d8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 19 23:37:53 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 20 14:40:39 2012 +0200

cmirrord: add test for closedir() and close()

---
 WHATS_NEW                    |    1 +
 daemons/cmirrord/functions.c |   13 +++++++++----
 daemons/cmirrord/local.c     |   14 ++++++++++----
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0158c6c..10fd724 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add tests for errors from closedir(), close() in cmirrord.
   Fix missing sync of filesystem when creating thin volume snapshot.
 
 Version 2.02.96 - 8th June 2012
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 96f7b8e..40b4bad 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -337,14 +337,18 @@ static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_pat
 		    (major(statbuf.st_rdev) == major) &&
 		    (minor(statbuf.st_rdev) == minor)) {
 			LOG_DBG("  %s: YES", dep->d_name);
-			closedir(dp);
+			if (closedir(dp))
+				LOG_DBG("Unable to closedir /dev/mapper %s",
+					strerror(errno));
 			return 0;
 		} else {
 			LOG_DBG("  %s: NO", dep->d_name);
 		}
 	}
 
-	closedir(dp);
+	if (closedir(dp))
+		LOG_DBG("Unable to closedir /dev/mapper %s",
+			strerror(errno));
 
 	/* FIXME Find out why this was here and deal with underlying problem. */
 	LOG_DBG("Path not found for %d/%d", major, minor);
@@ -640,8 +644,9 @@ static int clog_dtr(struct dm_ulog_request *rq)
 	LOG_DBG("[%s] Cluster log removed", SHORT_UUID(lc->uuid));
 
 	dm_list_del(&lc->list);
-	if (lc->disk_fd != -1)
-		close(lc->disk_fd);
+	if (lc->disk_fd != -1 && close(lc->disk_fd))
+		LOG_ERROR("Failed to close disk log: %s",
+			  strerror(errno));
 	if (lc->disk_buffer)
 		free(lc->disk_buffer);
 	dm_free(lc->clean_bits);
diff --git a/daemons/cmirrord/local.c b/daemons/cmirrord/local.c
index 8601cfd..50711a1 100644
--- a/daemons/cmirrord/local.c
+++ b/daemons/cmirrord/local.c
@@ -27,7 +27,7 @@
 #define CN_VAL_DM_USERSPACE_LOG         0x1
 #endif
 
-static int cn_fd;  /* Connector (netlink) socket fd */
+static int cn_fd = -1;  /* Connector (netlink) socket fd */
 static char recv_buf[2048];
 static char send_buf[2048];
 
@@ -384,14 +384,18 @@ int init_local(void)
 
 	r = bind(cn_fd, (struct sockaddr *) &addr, sizeof(addr));
 	if (r < 0) {
-		close(cn_fd);
+		if (close(cn_fd))
+			LOG_ERROR("Failed to close socket: %s",
+				  strerror(errno));
 		return EXIT_KERNEL_BIND;
 	}
 
 	opt = addr.nl_groups;
 	r = setsockopt(cn_fd, 270, NETLINK_ADD_MEMBERSHIP, &opt, sizeof(opt));
 	if (r) {
-		close(cn_fd);
+		if (close(cn_fd))
+			LOG_ERROR("Failed to close socket: %s",
+				  strerror(errno));
 		return EXIT_KERNEL_SETSOCKOPT;
 	}
 
@@ -412,5 +416,7 @@ int init_local(void)
 void cleanup_local(void)
 {
 	links_unregister(cn_fd);
-	close(cn_fd);
+	if (cn_fd >= 0 && close(cn_fd))
+		LOG_ERROR("Failed to close socket: %s",
+			  strerror(errno));
 }


