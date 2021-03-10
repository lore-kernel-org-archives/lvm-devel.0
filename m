From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:23 +0000 (GMT)
Subject: main - bcache: fix incorrect pointer check
Message-ID: <20210310003623.E1A7D385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17802084c90df4ced26ae395292f0fc8466e72b7
Commit:        17802084c90df4ced26ae395292f0fc8466e72b7
Parent:        d5f3239de4aa33f51cc8db7fc2e29db41cab9152
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 19:35:53 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 00:59:05 2021 +0100

bcache: fix incorrect pointer check

With commit b44db5d1a7ecc2e8e3cef0852c4397b64ddf0a09
needs to check allocated pointer for failed malloc().

Existing check was actually no checking anything so failing
malloc here would result in segfault (although with very
low chance to ever happen).
---
 lib/device/bcache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index a3803befb..a5f2a5a86 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -74,7 +74,7 @@ static struct cb_set *_cb_set_create(unsigned nr)
 	unsigned i;
 	struct cb_set *cbs = malloc(sizeof(*cbs) + nr * sizeof(*cbs->vec));
 
-	if (!cbs->vec)
+	if (!cbs)
 		return NULL;
 
 	dm_list_init(&cbs->free);


