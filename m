From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:36 +0000 (UTC)
Subject: master - clvmd: move destroy_lvm into lvm thread
Message-ID: <20140321213136.0A71260F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc39ad677b3f4ffe8d4bba975e1628fb8f141921
Commit:        fc39ad677b3f4ffe8d4bba975e1628fb8f141921
Parent:        8431d47b3b4d1742e9703a1abfd9722b94adaf34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 14:23:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:23 2014 +0100

clvmd: move destroy_lvm into lvm thread

Since lvm was initialized in lvm thread call destroy there as well.
---
 daemons/clvmd/clvmd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 4ca2918..4f6a6df 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -625,7 +625,6 @@ int main(int argc, char *argv[])
 		log_sys_error("pthread_join", "");
 
 	close_local_sock(local_sock);
-	destroy_lvm();
 
 	while ((delfd = local_client_head.next)) {
 		local_client_head.next = delfd->next;
@@ -2102,6 +2101,8 @@ static void *lvm_thread_fn(void *arg)
 
 	pthread_mutex_unlock(&lvm_thread_mutex);
 
+	destroy_lvm();
+
 	pthread_exit(NULL);
 }
 


