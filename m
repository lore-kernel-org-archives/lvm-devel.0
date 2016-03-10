From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:19 +0000 (UTC)
Subject: master - cleanup: add backtrace
Message-ID: <20160310174019.9613860DFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b36cf94318171d9cfe35cee38e4f323ad4c8a0a4
Commit:        b36cf94318171d9cfe35cee38e4f323ad4c8a0a4
Parent:        8e9deb2e701d495819d0a8c75f3a5e6c4240ad48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 7 10:20:35 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

cleanup: add backtrace

---
 libdaemon/client/daemon-client.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 677e8c4..413d757 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -25,11 +25,7 @@
 
 daemon_handle daemon_open(daemon_info i)
 {
-	daemon_handle h = {
-		.protocol = NULL,
-		.protocol_version = 0,
-		.error = 0
-	};
+	daemon_handle h = { .error = 0 };
 	daemon_reply r = { 0 };
 	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 
@@ -191,20 +187,22 @@ void daemon_close(daemon_handle h)
 daemon_request daemon_request_make(const char *id)
 {
 	daemon_request r;
-	r.cft = NULL;
+
 	buffer_init(&r.buffer);
 
 	if (!(r.cft = dm_config_create()))
-		goto bad;
+		goto_bad;
 
 	if (!(r.cft->root = make_text_node(r.cft, "request", id, NULL, NULL)))
-		goto bad;
+		goto_bad;
 
 	return r;
 bad:
-	if (r.cft)
+	if (r.cft) {
 		dm_config_destroy(r.cft);
-	r.cft = NULL;
+		r.cft = NULL;
+	}
+
 	return r;
 }
 


