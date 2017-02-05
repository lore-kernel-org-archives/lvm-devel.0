From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  5 Feb 2017 16:56:39 +0000 (UTC)
Subject: master - clvmd: add mutex protection for cpg_ call
Message-ID: <20170205165639.0A17460C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dae4f53acb269219e876c229c8f034fcdaf3ff5a
Commit:        dae4f53acb269219e876c229c8f034fcdaf3ff5a
Parent:        a4bbaa3b894f03e4ac21c979ec4e5201120703ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 4 14:47:27 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 5 17:55:37 2017 +0100

clvmd: add mutex protection for cpg_ call

The library for corosync multicasting is not supporting multithread
usage - add local mutex to avoid parallel call of cpg_mcast_joined().
---
 WHATS_NEW                      |    1 +
 daemons/clvmd/clvmd-corosync.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1c0ef6d..cbe6c05 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Avoid parallel usage of cpg_mcast_joined() in clvmd with corosync.
   Support raid6_{ls,rs,la,ra}_6 segment types and conversions from/to it.
   Support raid6_n_6 segment type and conversions from/to it.
   Support raid5_n segment type and conversions from/to it.
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index 05c9882..2227cbf 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -532,6 +532,7 @@ static int _cluster_fd_callback(struct local_client *fd, char *buf, int len,
 static int _cluster_send_message(const void *buf, int msglen, const char *csid,
 				 const char *errtext)
 {
+	static pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
 	struct iovec iov[2];
 	cs_error_t err;
 	int target_node;
@@ -546,7 +547,10 @@ static int _cluster_send_message(const void *buf, int msglen, const char *csid,
 	iov[1].iov_base = (char *)buf;
 	iov[1].iov_len = msglen;
 
+	pthread_mutex_lock(&_mutex);
 	err = cpg_mcast_joined(cpg_handle, CPG_TYPE_AGREED, iov, 2);
+	pthread_mutex_unlock(&_mutex);
+
 	return cs_to_errno(err);
 }
 


