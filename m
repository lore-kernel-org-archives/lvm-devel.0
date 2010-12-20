From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:16:31 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20101220131631.11350.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:16:30

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Test return value from read() and close() for an error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/tools/lvmcmdline.c	2010/11/30 11:53:33	1.134
+++ LVM2/tools/lvmcmdline.c	2010/12/20 13:16:30	1.135
@@ -1191,15 +1191,19 @@
 {
 	static char _proc_cmdline[32];
 	char buf[256];
-	int fd;
+	int fd, n = 0;
 
 	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/%u/cmdline", pid);
+	/* FIXME Use generic read code. */
 	if ((fd = open(buf, O_RDONLY)) > 0) {
-		read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1);
-		_proc_cmdline[sizeof(_proc_cmdline) - 1] = '\0';
-		close(fd);
-	} else
-		_proc_cmdline[0] = '\0';
+		if ((n = read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1)) < 0) {
+			log_sys_error("read", buf);
+			n = 0;
+		}
+		if (close(fd))
+			log_sys_error("close", buf);
+	}
+	_proc_cmdline[n] = '\0';
 
 	return _proc_cmdline;
 }


