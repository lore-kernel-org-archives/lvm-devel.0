From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:13 +0000 (GMT)
Subject: master - gcc: keep unsigned arithmetic
Message-ID: <20200828195913.10E4A3894C0C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce202c3b1c018a001015fa2ff69a01f06d84a6fa
Commit:        ce202c3b1c018a001015fa2ff69a01f06d84a6fa
Parent:        ff4827ffb1dbd568b988716c63634c96eb4c1e15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:55:01 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

gcc: keep unsigned arithmetic

Avoid conversion to int.
---
 lib/device/bcache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 7e7e18542..03cd4be87 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -66,7 +66,7 @@ struct cb_set {
 
 static struct cb_set *_cb_set_create(unsigned nr)
 {
-	int i;
+	unsigned i;
 	struct cb_set *cbs = malloc(sizeof(*cbs));
 
 	if (!cbs)


