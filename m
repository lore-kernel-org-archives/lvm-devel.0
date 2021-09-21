From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:05 +0000 (GMT)
Subject: main - cov: check strchr for NULL
Message-ID: <20210921195105.11C373858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bd55f8c152041101a27c83a96b794fdbb366460
Commit:        7bd55f8c152041101a27c83a96b794fdbb366460
Parent:        377e326156c74ef7aa7f5ac286bdabe3143a0b49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:24:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

cov: check strchr for NULL

Although unlikely, ensuring coverity we not use NULL.
---
 daemons/lvmlockd/lvmlockd-dlm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 68d18607c..1305c3dc2 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -801,7 +801,8 @@ int lm_refresh_lv_start_dlm(struct action *act)
 	strncpy(path, act->path, PATH_MAX-1);
 
 	/* skip past dev */
-	p = strchr(path + 1, '/');
+	if (!(p = strchr(path + 1, '/')))
+		return -EINVAL;
 
 	/* skip past slashes */
 	while (*p == '/')


