From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Apr 2011 14:55:25 +0200
Subject: [PATCH 2/5] Cast to 'int'
In-Reply-To: <cover.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
Message-ID: <7ef25f300a8bfeda9535d37cb63474bb6b78ac71.1303215346.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As we use both - unsigned and signed ints to decode major number - cast
it to 'int' to avoid warnings here.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/filters/filter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 07611f9..f63f8c2 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -21,7 +21,7 @@
 #include <sys/stat.h>
 
 #ifdef linux
-#  define MAJOR(dev)	((dev & 0xfff00) >> 8)
+#  define MAJOR(dev)	((int)(dev & 0xfff00) >> 8)
 #  define MINOR(dev)	((dev & 0xff) | ((dev >> 12) & 0xfff00))
 #  define MKDEV(ma,mi)	((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
 #else
-- 
1.7.4.4


