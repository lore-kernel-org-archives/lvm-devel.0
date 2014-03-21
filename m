From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:44 +0000 (UTC)
Subject: master - clvmd: drop unused local_sock parameter
Message-ID: <20140321213144.5525B610FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73978f8d7dd638806f514a7914884a204afd95c1
Commit:        73978f8d7dd638806f514a7914884a204afd95c1
Parent:        37396e2fe5c451c466f93f852a3559da023fc98c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 11:34:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:24 2014 +0100

clvmd: drop unused local_sock parameter

---
 daemons/clvmd/clvmd.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index c3268a7..572c5b7 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -132,7 +132,7 @@ static int open_local_sock(void);
 static void close_local_sock(int local_socket);
 static int check_local_clvmd(void);
 static struct local_client *find_client(int clientid);
-static void main_loop(int local_sock, int cmd_timeout);
+static void main_loop(int cmd_timeout);
 static void be_daemon(int start_timeout);
 static int check_all_clvmds_running(struct local_client *client);
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
@@ -615,7 +615,7 @@ int main(int argc, char *argv[])
 	signal(SIGINT, sigterm_handler);
 
 	/* Do some work */
-	main_loop(local_sock, cmd_timeout);
+	main_loop(cmd_timeout);
 
 	pthread_mutex_lock(&lvm_thread_mutex);
 	lvm_thread_exit = 1;
@@ -820,7 +820,7 @@ static void request_timed_out(struct local_client *client)
 }
 
 /* This is where the real work happens */
-static void main_loop(int local_sock, int cmd_timeout)
+static void main_loop(int cmd_timeout)
 {
 	sigset_t ss;
 


