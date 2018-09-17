From: David Teigland <teigland@sourceware.org>
Date: Mon, 17 Sep 2018 12:21:09 -0400
Subject: master - radix-tree: default to simple version
Message-ID: <201809171621.w8HGL9cv028399@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=41ef146dc3bf9bd2ecbcedb8c3cdbd2535149296
Commit:        41ef146dc3bf9bd2ecbcedb8c3cdbd2535149296
Parent:        fdb6ef8a85e9adc4805202b3200b17bd3b351982
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 17 11:19:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 17 11:19:53 2018 -0500

radix-tree: default to simple version

Avoid problems with the advanced version.
---
 base/Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index 1823c9b..ff77815 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -11,7 +11,8 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Uncomment this to build the simple radix tree.  You'll need to make clean too.
-# base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
+# Comment to build the advanced radix tree.
+base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
 
 BASE_SOURCE=\
 	base/data-struct/radix-tree.c \


