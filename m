From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:35 +0000 (GMT)
Subject: main - gcc: snprintf may need here upto 18 bytes
Message-ID: <20220126141035.D9A54385042E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf68bf7b6c5668dcaf16310e84636a79164bd8ee
Commit:        cf68bf7b6c5668dcaf16310e84636a79164bd8ee
Parent:        7f1f7ad694201533c04ddfbe9ba047f832b38750
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 20 15:24:09 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

gcc: snprintf may need here upto 18 bytes

Although hypothetical case....
---
 daemons/lvmlockd/lvmlockd-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 175f59331..6d0d4d98c 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4777,7 +4777,7 @@ static void client_recv_action(struct client *cl)
 	const char *path;
 	const char *str;
 	struct pvs pvs;
-	char buf[17];	/* "path[%d]\0", %d outputs signed integer so max to 10 bytes */
+	char buf[18];	/* "path[%d]\0", %d outputs signed integer so max to 10 bytes */
 	int64_t val;
 	uint32_t opts = 0;
 	int result = 0;


