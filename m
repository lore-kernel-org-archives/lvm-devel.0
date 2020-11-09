From: David Teigland <teigland@sourceware.org>
Date: Mon,  9 Nov 2020 15:47:44 +0000 (GMT)
Subject: main - writecache: supported in dm-writecache version 3
Message-ID: <20201109154744.D9364385781B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7058cfa989762ad33f115528d572cda80918cca
Commit:        d7058cfa989762ad33f115528d572cda80918cca
Parent:        8801a86a3e0c87d92b250a6477f86ef9efdb2ba0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 9 09:47:01 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 9 09:47:01 2020 -0600

writecache: supported in dm-writecache version 3

not version 2
---
 lib/writecache/writecache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 4ecbf50df..2cef9f26e 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -255,7 +255,7 @@ static int _target_present(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (min >= 2) {
+		if (min >= 3) {
 			_writecache_cleaner_supported = 1;
 			_writecache_max_age_supported = 1;
 		}


