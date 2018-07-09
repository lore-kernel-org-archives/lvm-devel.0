From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 04:38:41 -0400
Subject: master - build: not yet merged
Message-ID: <201807090838.w698cfHH025410@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b98846998b7719360e9d41f83a24101c8389bc70
Commit:        b98846998b7719360e9d41f83a24101c8389bc70
Parent:        5f3eff8eaecdb6e8f97b3904d5c43d36700709f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 10:37:39 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 10:37:39 2018 +0200

build: not yet merged

status.c will get linked with VDO support.
---
 test/unit/Makefile |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/unit/Makefile b/test/unit/Makefile
index aeed2d7..c2f992b 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -11,6 +11,8 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 UNIT_SOURCE=\
+	device_mapper/vdo/status.c \
+	\
 	test/unit/activation-generator_t.c \
 	test/unit/bcache_t.c \
 	test/unit/bcache_utils_t.c \


