From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:35 +0200
Subject: [PATCH 28/30] Skip uninitialized macro for scan-build
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <1191037c596039e3f71a01b02a4534b92fb39ec3.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

scan-build reports assigment of ununitialised values.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/util.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/misc/util.h b/lib/misc/util.h
index fcda369..59e6980 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -25,7 +25,11 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })
 
+#ifndef  __clang__
 #define uninitialized_var(x) x = x
+#else
+#define uninitialized_var(x) x
+#endif
 
 #define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
 
-- 
1.7.3.1


