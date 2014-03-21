From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:52 +0000 (UTC)
Subject: master - cleanup: clvmd move destroy_lvhash into main
Message-ID: <20140321213152.A577260F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf19c6be2c57c43ebc6c7ceb85fd7487c7e36799
Commit:        bf19c6be2c57c43ebc6c7ceb85fd7487c7e36799
Parent:        1ee8688de097968655d98f0f7f266945a92f20a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 14:06:16 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:25 2014 +0100

cleanup: clvmd move destroy_lvhash into main

Keep destruction code path consistent and simple and
destroy lvhash in the place it's been created.
Also issue debug message from a single place.
---
 daemons/clvmd/clvmd-cman.c       |    1 -
 daemons/clvmd/clvmd-corosync.c   |    3 ---
 daemons/clvmd/clvmd-openais.c    |    3 ---
 daemons/clvmd/clvmd-singlenode.c |    2 --
 daemons/clvmd/clvmd.c            |    2 ++
 5 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index 7e76dc4..e41d0cf 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -245,7 +245,6 @@ static void _add_up_node(const char *csid)
 
 static void _cluster_closedown()
 {
-	destroy_lvhash();
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cman_finish(c_handle);
 }
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index e68cb73..be51b61 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -345,9 +345,6 @@ static int _init_cluster(void)
 
 static void _cluster_closedown(void)
 {
-	DEBUGLOG("cluster_closedown\n");
-	destroy_lvhash();
-
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cpg_finalize(cpg_handle);
 	quorum_finalize(quorum_handle);
diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 77c0482..c91a238 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -365,9 +365,6 @@ static int _init_cluster(void)
 
 static void _cluster_closedown(void)
 {
-	DEBUGLOG("cluster_closedown\n");
-	destroy_lvhash();
-
 	saLckFinalize(lck_handle);
 	cpg_finalize(cpg_handle);
 }
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index a3a1960..e65ab28 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -121,8 +121,6 @@ static void _cluster_closedown(void)
 {
 	close_comms();
 
-	DEBUGLOG("cluster_closedown\n");
-	destroy_lvhash();
 	/* If there is any awaited resource, kill it softly */
 	pthread_mutex_lock(&_lock_mutex);
 	dm_hash_destroy(_locks);
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index dd3548f..05e5670 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -636,6 +636,8 @@ int main(int argc, char *argv[])
 		dm_free(delfd);
 	}
 
+	DEBUGLOG("cluster_closedown\n");
+	destroy_lvhash();
 	clops->cluster_closedown();
 
 	ret = 0;


