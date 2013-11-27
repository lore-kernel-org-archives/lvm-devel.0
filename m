From: dongmao zhang <dmzhang@suse.com>
Date: Wed, 27 Nov 2013 16:56:44 +0800
Subject: [PATCH] clvmd: closedown the cluster after finishing of lvm_thread
Message-ID: <1385542604-11708-1-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

when lvm_thread is processing remote request, the clvmd
received a SIG_TERM, it will free cluster resource before
the realwork of lvm_thread is done. If freeing the cluster
resource happens before send_message, it would cause the
remote command hangs forever.

this patch move closedown after the closing the working thread.
---
 daemons/clvmd/clvmd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index d57c0fd..b2f7dd5 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -621,6 +621,8 @@ int main(int argc, char *argv[])
 	if ((errno = pthread_join(lvm_thread, NULL)))
 		log_sys_error("pthread_join", "");
 
+	clops->cluster_closedown();
+
 	close_local_sock(local_sock);
 	destroy_lvm();
 
@@ -979,7 +981,6 @@ static void main_loop(int local_sock, int cmd_timeout)
 	}
 
       closedown:
-	clops->cluster_closedown();
 	if (quit)
 		DEBUGLOG("SIGTERM received\n");
 }
-- 
1.7.3.4


