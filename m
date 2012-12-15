From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:42 +0000 (UTC)
Subject: master - lvmetad: fix socket leak in handle_connect
Message-ID: <20121215162542.AF7F0AAB82@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4008f4f891c948c1629ed0ee50e04d4c26001d0c
Commit:        4008f4f891c948c1629ed0ee50e04d4c26001d0c
Parent:        e012d0635d34edd98652c9425abb618a9565077a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 21:31:22 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

lvmetad: fix socket leak in handle_connect

Close socket_fd and report error on malloc failure.
---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2fc8acf..701d502 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix socket leak on error path in lvmetad's handle_connect.
   Check for failing id_read_format() in _pv_populate_lvmcache.
   Fix memleak on error path for lvmetad's pv_found.
   Unlock vg mutex in error path when lvmetad tries to lock_vg.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 3711419..3c84e11 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -427,8 +427,12 @@ static int handle_connect(daemon_state s)
 	if (client.socket_fd < 0)
 		return 0;
 
-	if (!(baton = malloc(sizeof(struct thread_baton))))
+	if (!(baton = malloc(sizeof(struct thread_baton)))) {
+		if (close(client.socket_fd))
+			perror("close");
+		ERROR(&s, "Failed to allocate thread baton");
 		return 0;
+	}
 
 	baton->s = s;
 	baton->client = client;


