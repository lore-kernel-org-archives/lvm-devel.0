From: Leo Yan <leo.yan@linaro.org>
Date: Fri, 21 May 2021 10:56:37 +0800
Subject: [PATCH] configure: Add macro LOCKDIDM_SUPPORT
Message-ID: <20210521025638.2050724-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The macro LOCKDIDM_SUPPORT is missed in configure.h.in file, thus when
execute "configure" command, it has no chance to add this macro in the
automatic generated header include/configure.h.

This patch adds macro LOCKDIDM_SUPPORT into configure.h.in.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 include/configure.h.in | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/configure.h.in b/include/configure.h.in
index 671d201b2..bcb282660 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -561,6 +561,9 @@
 /* Define to 1 to include code that uses lvmlockd sanlock option. */
 #undef LOCKDSANLOCK_SUPPORT
 
+/* Define to 1 to include code that uses lvmlockd IDM option. */
+#undef LOCKDIDM_SUPPORT
+
 /* Define to 1 if `lstat' dereferences a symlink specified with a trailing
    slash. */
 #undef LSTAT_FOLLOWS_SLASHED_SYMLINK
-- 
2.25.1


