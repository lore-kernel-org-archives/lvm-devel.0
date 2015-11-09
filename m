From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:07 +0000 (UTC)
Subject: master - clvmd: check for pthread_create status
Message-ID: <20151109092807.8849E606F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9df3069083cd49f75e0ec54fc1e699b057129934
Commit:        9df3069083cd49f75e0ec54fc1e699b057129934
Parent:        2c8d6f5c90d5be62b48ba2881f2a6631091dc5af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:23:27 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:18 2015 +0100

clvmd: check for pthread_create status

Coverity: likes to see checked function result.
---
 daemons/clvmd/clvmd.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 53daa8c..96cb697 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -604,7 +604,10 @@ int main(int argc, char *argv[])
 		 local_client_head.fd, &local_client_head, newfd->fd, newfd);
 
 	/* Don't let anyone else to do work until we are started */
-	pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params);
+	if (pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params)) {
+		log_sys_error("pthread_create", "");
+		goto out;
+	}
 
 	/* Don't start until the LVM thread is ready */
 	pthread_barrier_wait(&lvm_start_barrier);


