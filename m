From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 20 Sep 2018 09:49:12 -0400
Subject: master - Merge branch '2018-09-13-radix-tree-bug'
Message-ID: <201809201349.w8KDnCOb008599@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8424655af9eed2f2422c904f8d3fa312fe61d00f
Commit:        8424655af9eed2f2422c904f8d3fa312fe61d00f
Parent:        945d13541e50a25f859e471abea4d86f00ce0964 bda4f3a7ae5a3879105466d24fa274dd1a3e5c7b
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Sep 20 14:43:51 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Sep 20 14:43:51 2018 +0100

Merge branch '2018-09-13-radix-tree-bug'


 base/Makefile                          |    2 +-
 base/data-struct/radix-tree-adaptive.c |   48 +-
 test/unit/Makefile                     |    2 +
 test/unit/radix_tree_t.c               |   60 ++
 test/unit/rt_case1.c                   | 1669 ++++++++++++++++++++++++++++++++
 5 files changed, 1769 insertions(+), 12 deletions(-)

diff --cc base/Makefile
index ff77815,7b21ca5..e30cb44
--- a/base/Makefile
+++ b/base/Makefile
@@@ -11,8 -11,7 +11,8 @@@
  # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  
  # Uncomment this to build the simple radix tree.  You'll need to make clean too.
 +# Comment to build the advanced radix tree.
- base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
+ #base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
  
  BASE_SOURCE=\
  	base/data-struct/radix-tree.c \


