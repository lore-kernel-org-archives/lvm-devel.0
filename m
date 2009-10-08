From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:09 +0200
Subject: [PATCH 02/11] debian: drop realtime
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <ed17d1525f4431ee900974ee84df19a351b005b5.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-ID: <20091008124909.BtD2MfrgFLeRyyheuPoM2nTYnj1XXl3FhJyL7uwrBr4@z>

From: Fabio M. Di Nitto <fdinitto@redhat.com>

the realtime support is completely unused and just includes another library
dependency

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 b4e7f28... 45dc2c9... M	configure.in
:100644 100644 2bd6fba... d4e24d4... M	lib/Makefile.in
:100644 000000 62e1be8... 0000000... D	lib/misc/timestamp.c
:100644 000000 50e2a85... 0000000... D	lib/misc/timestamp.h
 configure.in         |   23 ---------
 lib/Makefile.in      |    1 -
 lib/misc/timestamp.c |  130 --------------------------------------------------
 lib/misc/timestamp.h |   33 -------------
 4 files changed, 0 insertions(+), 187 deletions(-)

diff --git a/configure.in b/configure.in
index b4e7f28..45dc2c9 100644
--- a/configure.in
+++ b/configure.in
@@ -40,7 +40,6 @@ case "$host_os" in
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
-		REALTIME=yes
 		CLUSTER=internal
 		FSADM=yes
 		;;
@@ -55,7 +54,6 @@ case "$host_os" in
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
-		REALTIME=no
 		CLUSTER=none
 		FSADM=no
 		;;
@@ -316,13 +314,6 @@ AC_ARG_ENABLE([readline],
 AC_MSG_RESULT($READLINE)
 
 ################################################################################
-dnl -- Disable realtime clock support
-AC_MSG_CHECKING(whether to enable realtime support)
-AC_ARG_ENABLE(realtime, [  --disable-realtime      Disable realtime clock support],
-REALTIME=$enableval)
-AC_MSG_RESULT($REALTIME)
-
-################################################################################
 dnl -- Init pkg-config with dummy invokation:
 dnl -- this is required because PKG_CHECK_MODULES macro is expanded
 dnl -- to initialize the pkg-config environment only at the first invokation,
@@ -868,19 +859,6 @@ if test x$SELINUX = xyes; then
 fi
 
 ################################################################################
-dnl -- Check for realtime clock support
-if test x$REALTIME = xyes; then
-	AC_CHECK_LIB(rt, clock_gettime, HAVE_REALTIME=yes, HAVE_REALTIME=no)
-
-	if test x$HAVE_REALTIME = xyes; then
-		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
-		LIBS="-lrt $LIBS"
-	else
-		AC_MSG_WARN(Disabling realtime clock)
-	fi
-fi
-
-################################################################################
 dnl -- Check for getopt
 AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getopt_long is available.]))
 
@@ -1098,7 +1076,6 @@ AC_SUBST(GROUP)
 AC_SUBST(GULM_CFLAGS)
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
-AC_SUBST(HAVE_REALTIME)
 AC_SUBST(HAVE_SELINUX)
 AC_SUBST(INTL)
 AC_SUBST(INTL_PACKAGE)
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 2bd6fba..d4e24d4 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -82,7 +82,6 @@ SOURCES =\
 	misc/lvm-globals.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
-	misc/timestamp.c \
 	misc/util.c \
 	mm/memlock.c \
 	report/report.c \
diff --git a/lib/misc/timestamp.c b/lib/misc/timestamp.c
deleted file mode 100644
index 62e1be8..0000000
--- a/lib/misc/timestamp.c
+++ /dev/null
@@ -1,130 +0,0 @@
-/*
- * Copyright (C) 2006 Rackable Systems All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-/*
- * Abstract out the time methods used so they can be adjusted later -
- * the results of these routines should stay in-core.  This implementation
- * requires librt.
- */
-
-#include "lib.h"
-#include <stdlib.h>
-
-#include "timestamp.h"
-
-/*
- * The realtime section uses clock_gettime with the CLOCK_MONOTONIC
- * parameter to prevent issues with time warps
- */
-#ifdef HAVE_REALTIME
-
-#include <time.h>
-#include <bits/time.h>
-
-struct timestamp {
-	struct timespec t;
-};
-
-struct timestamp *get_timestamp(void)
-{
-	struct timestamp *ts = NULL;
-
-	if (!(ts = dm_malloc(sizeof(*ts))))
-		return_NULL;
-
-	if (clock_gettime(CLOCK_MONOTONIC, &ts->t)) {
-		log_sys_error("clock_gettime", "get_timestamp");
-		return NULL;
-	}
-
-	return ts;
-}
-
-/* cmp_timestamp: Compare two timestamps
- *
- * Return: -1 if t1 is less than t2
- *          0 if t1 is equal to t2
- *          1 if t1 is greater than t2
- */
-int cmp_timestamp(struct timestamp *t1, struct timestamp *t2)
-{
-	if(t1->t.tv_sec < t2->t.tv_sec)
-		return -1;
-	if(t1->t.tv_sec > t2->t.tv_sec)
-		return 1;
-
-	if(t1->t.tv_nsec < t2->t.tv_nsec)
-		return -1;
-	if(t1->t.tv_nsec > t2->t.tv_nsec)
-		return 1;
-
-	return 0;
-}
-
-#else /* ! HAVE_REALTIME */
-
-/*
- * The !realtime section just uses gettimeofday and is therefore subject
- * to ntp-type time warps - not sure if should allow that.
- */
-
-#include <sys/time.h>
-
-struct timestamp {
-	struct timeval t;
-};
-
-struct timestamp *get_timestamp(void)
-{
-	struct timestamp *ts = NULL;
-
-	if (!(ts = dm_malloc(sizeof(*ts))))
-		return_NULL;
-
-	if (gettimeofday(&ts->t, NULL)) {
-		log_sys_error("gettimeofday", "get_timestamp");
-		return NULL;
-	}
-
-	return ts;
-}
-
-/* cmp_timestamp: Compare two timestamps
- *
- * Return: -1 if t1 is less than t2
- *          0 if t1 is equal to t2
- *          1 if t1 is greater than t2
- */
-int cmp_timestamp(struct timestamp *t1, struct timestamp *t2)
-{
-	if(t1->t.tv_sec < t2->t.tv_sec)
-		return -1;
-	if(t1->t.tv_sec > t2->t.tv_sec)
-		return 1;
-
-	if(t1->t.tv_usec < t2->t.tv_usec)
-		return -1;
-	if(t1->t.tv_usec > t2->t.tv_usec)
-		return 1;
-
-	return 0;
-}
-
-#endif /* HAVE_REALTIME */
-
-void destroy_timestamp(struct timestamp *t)
-{
-	if (t)
-		dm_free(t);
-}
diff --git a/lib/misc/timestamp.h b/lib/misc/timestamp.h
deleted file mode 100644
index 50e2a85..0000000
--- a/lib/misc/timestamp.h
+++ /dev/null
@@ -1,33 +0,0 @@
-/*
- * Copyright (C) 2006 Rackable Systems All rights reserved.  
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_TIMESTAMP_H
-#define _LVM_TIMESTAMP_H
-
-struct timestamp;
-
-struct timestamp *get_timestamp(void);
-
-/* cmp_timestamp: Compare two timestamps
- * 
- * Return: -1 if t1 is less than t2
- *  	    0 if t1 is equal to t2
- *          1 if t1 is greater than t2
- */
-int cmp_timestamp(struct timestamp *t1, struct timestamp *t2);
-
-void destroy_timestamp(struct timestamp *t);
-
-#endif /* _LVM_TIMESTAMP_H */
-
-- 
1.5.4.3


