From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:08 +0000 (UTC)
Subject: master - clmvd: fix responce status
Message-ID: <20130421211610.5D07D145A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9d8d22224f5516f364bd66ce41aa506a39801a6
Commit:        c9d8d22224f5516f364bd66ce41aa506a39801a6
Parent:        764195207d4773cf6f1674a2fb16e9a0acda304a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:11:32 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 22:54:42 2013 +0200

clmvd: fix responce status

Failing status code is expected to be 0.
Also do not return '*response' as pointer which has been already free().
---
 WHATS_NEW                     |    1 +
 daemons/clvmd/refresh_clvmd.c |   15 ++++++---------
 lib/locking/cluster_locking.c |   10 ++++------
 3 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 76347e9..95b6e13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix clvmd _cluster_request() return code in memory fail path.
   Add writemostly/writebehind support for RAID1
   Add lv_change_activate() for common activation code in vg/lvchange.
   Revert change that allowed identical table reload for RAID.
diff --git a/daemons/clvmd/refresh_clvmd.c b/daemons/clvmd/refresh_clvmd.c
index 28b5625..42c3958 100644
--- a/daemons/clvmd/refresh_clvmd.c
+++ b/daemons/clvmd/refresh_clvmd.c
@@ -225,16 +225,14 @@ static int _cluster_request(char cmd, const char *node, void *data, int len,
 	 * With an extra pair of INTs on the front to sanity
 	 * check the pointer when we are given it back to free
 	 */
-	*response = dm_malloc(sizeof(lvm_response_t) * num_responses +
-			    sizeof(int) * 2);
-	if (!*response) {
+	*response = NULL;
+	if (!(rarray = dm_malloc(sizeof(lvm_response_t) * num_responses +
+				 sizeof(int) * 2))) {
 		errno = ENOMEM;
 		status = 0;
 		goto out;
 	}
 
-	rarray = *response;
-
 	/* Unpack the response into an lvm_response_t array */
 	inptr = head->args;
 	i = 0;
@@ -251,9 +249,9 @@ static int _cluster_request(char cmd, const char *node, void *data, int len,
 			int j;
 			for (j = 0; j < i; j++)
 				dm_free(rarray[i].response);
-			free(*response);
+			dm_free(rarray);
 			errno = ENOMEM;
-			status = -1;
+			status = 0;
 			goto out;
 		}
 
@@ -266,8 +264,7 @@ static int _cluster_request(char cmd, const char *node, void *data, int len,
 	*response = rarray;
 
       out:
-	if (retbuf)
-		dm_free(retbuf);
+	dm_free(retbuf);
 
 	return status;
 }
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 01a47b0..3169f0d 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -241,15 +241,13 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 	 * With an extra pair of INTs on the front to sanity
 	 * check the pointer when we are given it back to free
 	 */
-	*response = dm_malloc(sizeof(lvm_response_t) * num_responses);
-	if (!*response) {
+	*response = NULL;
+	if (!(rarray = dm_malloc(sizeof(lvm_response_t) * num_responses))) {
 		errno = ENOMEM;
 		status = 0;
 		goto out;
 	}
 
-	rarray = *response;
-
 	/* Unpack the response into an lvm_response_t array */
 	inptr = head->args;
 	i = 0;
@@ -266,9 +264,9 @@ static int _cluster_request(char clvmd_cmd, const char *node, void *data, int le
 			int j;
 			for (j = 0; j < i; j++)
 				dm_free(rarray[i].response);
-			free(*response);
+			dm_free(rarray);
 			errno = ENOMEM;
-			status = -1;
+			status = 0;
 			goto out;
 		}
 


