From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:18 +0000 (GMT)
Subject: main - debug: keep microseconds aligned
Message-ID: <20210315101418.5D09D3857C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e9ccf7b6f58cd3e31a79c35d3a312560809e85a
Commit:        6e9ccf7b6f58cd3e31a79c35d3a312560809e85a
Parent:        bc1bc4cffc2b5faa113b5c232aa5fc2faae8771a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 12 22:39:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

debug: keep microseconds aligned

---
 lib/log/log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index cd676f2ae..53ff5b156 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -472,7 +472,7 @@ static void _set_time_prefix(char *prefix, int buflen)
 	if (!len)
 		goto fail;
 
-	len = dm_snprintf(prefix + len, buflen - len, ".%ld ", ts.tv_nsec/1000);
+	len = dm_snprintf(prefix + len, buflen - len, ".%06ld ", ts.tv_nsec/1000);
 	if (len < 0)
 		goto fail;
 


