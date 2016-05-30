From: Tobias Stoeckmann <tobias@stoeckmann.org>
Date: Mon, 30 May 2016 23:13:40 +0200
Subject: [PATCH] Fixed typo in lvcreate.8
Message-ID: <20160530211340.GA21449@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's supposed to be "smaller than" instead of "smaller then".
---
 man/lvcreate.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 8614cb1..c28bc41 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -261,7 +261,7 @@ and the default value is 4KiB.
 For cache pools the value must a multiple of 32KiB
 between 32KiB and 1GiB. The default is 64KiB.
 When the size is specified with volume caching, it may not be smaller
-then cache pool creation chunk size was.
+than cache pool creation chunk size was.
 .br
 For thin pools the value must be a multiple of 64KiB
 between 64KiB and 1GiB.
-- 
2.8.3


