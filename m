From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:43:01 +0100
Subject: [PATCH 15/15] Update generated misc/configure.in
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <6ad7098b333466407a00476cc2f6c63b19f0eb9e.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This file is generated from autoreconf.
HAVE_LIBREADLINE is no longer defined
- lvm does not use it anyway.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/configure.h.in |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 4273eeb..b0af63f 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -120,9 +120,6 @@
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 
-/* Define to 1 if you have the `readline' library (-lreadline). */
-#undef HAVE_LIBREADLINE
-
 /* Define to 1 if you have the <limits.h> header file. */
 #undef HAVE_LIMITS_H
 
-- 
1.7.0


