From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 20 Sep 2018 09:49:14 -0400
Subject: master - [build] switch back to the adaptive radix tree
Message-ID: <201809201349.w8KDnEfs008619@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bda4f3a7ae5a3879105466d24fa274dd1a3e5c7b
Commit:        bda4f3a7ae5a3879105466d24fa274dd1a3e5c7b
Parent:        ba6d8a319515b7c156999cc978c49d969a2b14a6
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Sep 20 14:40:28 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Sep 20 14:40:28 2018 +0100

[build] switch back to the adaptive radix tree

---
 base/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index 1823c9b..7b21ca5 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Uncomment this to build the simple radix tree.  You'll need to make clean too.
-# base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
+#base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
 
 BASE_SOURCE=\
 	base/data-struct/radix-tree.c \


