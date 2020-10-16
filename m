From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:45 +0000 (GMT)
Subject: stable-2.02 - gcc: keep unsigned arithmetic
Message-ID: <20201016191045.F3066396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90a9a7785e7ad82f6878bb0520989b5b3df00f22
Commit:        90a9a7785e7ad82f6878bb0520989b5b3df00f22
Parent:        94b5aa0aad3173b19c7424996e28dfdc276a34d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:55:01 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

gcc: keep unsigned arithmetic

Avoid conversion to int.
---
 lib/device/bcache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 03779a519..e4e72b6fb 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -66,7 +66,7 @@ struct cb_set {
 
 static struct cb_set *_cb_set_create(unsigned nr)
 {
-	int i;
+	unsigned i;
 	struct cb_set *cbs = malloc(sizeof(*cbs));
 
 	if (!cbs)


