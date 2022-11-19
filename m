From: David Seifert <soap@gentoo.org>
Date: Sat, 19 Nov 2022 17:51:09 +0100
Subject: [PATCH 2/2] Fix `strerror_r` check for musl
In-Reply-To: <20221119165109.1225726-1-soap@gentoo.org>
References: <20221119165109.1225726-1-soap@gentoo.org>
Message-ID: <20221119165109.1225726-2-soap@gentoo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Sam James <sam@gentoo.org>

* We can't assume that strerror_r returns char* just because _GNU_SOURCE is
  defined. We already call the appropriate autoconf test, so let's use its
  result (STRERROR_R_CHAR_P).

  Note that in configure, _GNU_SOURCE is always set, but we add a defined
  guard just in case for futureproofing.

Bug: https://bugs.gentoo.org/869404
---
 daemons/lvmpolld/lvmpolld-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 47c9376b4..a75f71e2f 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -52,7 +52,7 @@ static pthread_key_t key;
 
 static const char *_strerror_r(int errnum, struct lvmpolld_thread_data *data)
 {
-#ifdef _GNU_SOURCE
+#if defined(_GNU_SOURCE) && defined(STRERROR_R_CHAR_P)
 	return strerror_r(errnum, data->buf, sizeof(data->buf)); /* never returns NULL */
 #elif (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600)
 	return strerror_r(errnum, data->buf, sizeof(data->buf)) ? "" : data->buf;
-- 
2.38.1

