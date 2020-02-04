From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:45 -0500
Subject: master - cov: check error code from mutex init
Message-ID: <18956.120020411223902209@us-mta-27.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=555d6d4e62b5a10a8f52454a93e3cdc65e0d1abd
Commit:        555d6d4e62b5a10a8f52454a93e3cdc65e0d1abd
Parent:        d6ac039b65a371caeabb1bf2a191e609ed2cd9f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 12:48:40 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

cov: check error code from mutex init

---
 daemons/dmeventd/dmeventd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index ae1e6a6..4fcb381 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2237,7 +2237,8 @@ int main(int argc, char *argv[])
 
 	_init_thread_signals();
 
-	pthread_mutex_init(&_global_mutex, NULL);
+	if (pthread_mutex_init(&_global_mutex, NULL))
+		exit(EXIT_FAILURE);
 
 	if (!_systemd_activation && !_open_fifos(&fifos))
 		exit(EXIT_FIFO_FAILURE);



