From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:03 +0000 (GMT)
Subject: main - cov: ensuring buffer is zeroed
Message-ID: <20210921195103.E66D73858C3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=377e326156c74ef7aa7f5ac286bdabe3143a0b49
Commit:        377e326156c74ef7aa7f5ac286bdabe3143a0b49
Parent:        8c4459782000ffe8b6c21a710e15464f5905ab3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:13:05 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

cov: ensuring buffer is zeroed

---
 daemons/lvmlockd/lvmlockctl.c   | 1 +
 daemons/lvmlockd/lvmlockd-dlm.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 32da99c6d..45569e694 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -457,6 +457,7 @@ retry:
 	if (count < dump_len)
 		goto retry;
 
+	dump_buf[count] = 0;
 	rv = 0;
 	if ((info && dump) || !strcmp(req_name, "dump"))
 		printf("%s\n", dump_buf);
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 67e7bee03..68d18607c 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -119,6 +119,7 @@ static int read_cluster_name(char *clustername)
 			log_error(close_error_msg, fd);
 		return rv;
 	}
+	clustername[rv] = 0;
 
 	n = strstr(clustername, "\n");
 	if (n)


