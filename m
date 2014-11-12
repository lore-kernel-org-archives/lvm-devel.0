From: saulery@free.fr <saulery@free.fr>
Date: Wed, 12 Nov 2014 13:39:36 +0100
Subject: lvconvert.8: fix bold and italic syntax mistake
In-Reply-To: <1415795977-4518-1-git-send-email-saulery@free.fr>
References: <1415795977-4518-1-git-send-email-saulery@free.fr>
Message-ID: <1415795977-4518-2-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/lvconvert.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index bf699ee..5c9c083 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -416,7 +416,7 @@ and
 Sets the size of cache or thin pool's metadata logical volume,
 if the pool metadata volume is undefined.
 Pool is specified with the option
-\B\-\-cachepool\P or \fB\-\-thinpool\fP.
+\fB\-\-cachepool\fP or \fB\-\-thinpool\fP.
 For thin pool supported value is in the range between 2MiB and 16GiB.
 The default value is estimated with this formula
 (Pool_LV_size / Pool_LV_chunk_size * 64b).
-- 
2.1.1


