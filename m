From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Nov 2022 15:43:00 +0000 (GMT)
Subject: main - lvmpolld: fix `strerror_r` check for musl
Message-ID: <20221125154300.356B4384F482@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdd8feb60e7a7757aaa12d9df357cadeb1c31044
Commit:        fdd8feb60e7a7757aaa12d9df357cadeb1c31044
Parent:        3dee7b7266f79aba12805dfbfcd770dac3171051
Author:        Sam James <sam@gentoo.org>
AuthorDate:    Sat Nov 19 17:51:09 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:55:23 2022 +0100

lvmpolld: fix `strerror_r` check for musl

We can't assume that strerror_r returns char* just because _GNU_SOURCE is
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

