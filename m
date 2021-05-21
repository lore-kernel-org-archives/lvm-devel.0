From: David Teigland <teigland@sourceware.org>
Date: Fri, 21 May 2021 14:27:46 +0000 (GMT)
Subject: main - configure: Add macro LOCKDIDM_SUPPORT
Message-ID: <20210521142746.E5C3B38515FC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=102294f9788f243509f1001a60924d6920fd9092
Commit:        102294f9788f243509f1001a60924d6920fd9092
Parent:        8b904dc71143f4dc7553026f783aa1c0b1d4b954
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Fri May 21 10:56:37 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 21 09:27:30 2021 -0500

configure: Add macro LOCKDIDM_SUPPORT

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


