From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Jun 2009 12:15:24 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20090615121524.30828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-15 12:15:24

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c lvm-functions.c lvm-functions.h 

Log message:
	Destroy toolcontext on exit in clvmd (fixes memory pool leaks).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1149&r2=1.1150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2009/06/15 12:08:59	1.1149
+++ LVM2/WHATS_NEW	2009/06/15 12:15:23	1.1150
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Destroy toolcontext on exit in clvmd (fixes memory pool leaks).
   Fix lvconvert to not poll mirror if no conversion in progress.
   Fix memory leaks in toolcontext error path.
   Re-instate partial activation support in clustered mode. (2.02.40)
--- LVM2/daemons/clvmd/clvmd.c	2009/05/19 10:39:00	1.58
+++ LVM2/daemons/clvmd/clvmd.c	2009/06/15 12:15:23	1.59
@@ -481,6 +481,8 @@
 	/* Do some work */
 	main_loop(local_sock, cmd_timeout);
 
+	destroy_lvm();
+
 	return 0;
 }
 
--- LVM2/daemons/clvmd/lvm-functions.c	2009/06/12 08:30:19	1.62
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/06/15 12:15:23	1.63
@@ -811,3 +811,10 @@
 
 	return 1;
 }
+
+void destroy_lvm(void)
+{
+	if (cmd)
+		destroy_toolcontext(cmd);
+	cmd = NULL;
+}
--- LVM2/daemons/clvmd/lvm-functions.h	2009/05/19 10:39:00	1.10
+++ LVM2/daemons/clvmd/lvm-functions.h	2009/06/15 12:15:23	1.11
@@ -28,6 +28,7 @@
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
 extern int init_lvm(int using_gulm);
+extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
 extern void lvm_do_backup(const char *vgname);


