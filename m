From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 21:53:47 -0000
Subject: LVM2 daemons/dmeventd/dmeventd.c libdm/libdm-c ...
Message-ID: <20110329215347.24473.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 21:53:47

Modified files:
	daemons/dmeventd: dmeventd.c 
	libdm          : libdm-common.c 

Log message:
	Add attribute printf
	
	gcc suggested to add these attributes to instrumentat
	printf arguments. Adding it for internal functions as well.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/daemons/dmeventd/dmeventd.c	2011/03/29 20:30:06	1.78
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/03/29 21:53:46	1.79
@@ -567,6 +567,7 @@
 	pthread_mutex_unlock(&_timeout_mutex);
 }
 
+__attribute__((format(printf, 4, 5)))
 static void _no_intr_log(int level, const char *file, int line,
 			const char *f, ...)
 {
--- LVM2/libdm/libdm-common.c	2011/03/18 13:21:02	1.114
+++ LVM2/libdm/libdm-common.c	2011/03/29 21:53:47	1.115
@@ -78,6 +78,7 @@
  * function.
  */
 
+__attribute__((format(printf, 5, 0)))
 static void _default_log_line(int level,
 	    const char *file __attribute__((unused)),
 	    int line __attribute__((unused)), int dm_errno, 
@@ -101,6 +102,7 @@
 		fprintf(use_stderr ? stderr : stdout, "\n");
 }
 
+__attribute__((format(printf, 5, 6)))
 static void _default_log_with_errno(int level,
 	    const char *file __attribute__((unused)),
 	    int line __attribute__((unused)), int dm_errno, 
@@ -113,6 +115,7 @@
 	va_end(ap);
 }
 
+__attribute__((format(printf, 4, 5)))
 static void _default_log(int level, const char *file,
 			 int line, const char *f, ...)
 {


