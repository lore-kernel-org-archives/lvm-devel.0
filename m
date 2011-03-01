From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Mar 2011 20:17:57 -0000
Subject: LVM2 daemons/clvmd/clvmd.c daemons/dmeventd/li ...
Message-ID: <20110301201757.16459.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-01 20:17:56

Modified files:
	daemons/clvmd  : clvmd.c 
	daemons/dmeventd: libdevmapper-event.c 
	lib/display    : display.c display.h 

Log message:
	Fix some compile warnings on RHEL5
	- returned char not needed to be explicitly const
	- warn if pipe() fails in clvmd (more fixes here needed for error paths...)
	- assign (and ignore) read() output in drain buffer

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/daemons/clvmd/clvmd.c	2011/02/28 19:50:15	1.96
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/01 20:17:56	1.97
@@ -1007,7 +1007,10 @@
 		exit(3);
 	}
 
-	pipe(child_pipe);
+	if (pipe(child_pipe)) {
+		perror("Error creating pipe");
+		exit(3);
+	}
 
 	switch (fork()) {
 	case -1:
@@ -1254,7 +1257,9 @@
 		}
 
 		/* Create a pipe and add the reading end to our FD list */
-		pipe(comms_pipe);
+		if (pipe(comms_pipe))
+			DEBUGLOG("creating pipe failed: %s\n", strerror(errno));
+		
 		newfd = malloc(sizeof(struct local_client));
 		if (!newfd) {
 			struct clvm_header reply;
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2011/01/06 10:45:41	1.39
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2011/03/01 20:17:56	1.40
@@ -309,7 +309,7 @@
 		}
 		if (ret == 0)
 			break;
-		read(fifos->server, drainbuf, 127);
+		ret = read(fifos->server, drainbuf, 127);
 	}
 
 	while (bytes < size) {
--- LVM2/lib/display/display.c	2011/02/18 23:09:55	1.116
+++ LVM2/lib/display/display.c	2011/03/01 20:17:56	1.117
@@ -131,7 +131,7 @@
 		return v * multiplier;
 }
 
-const char alloc_policy_char(alloc_policy_t alloc)
+char alloc_policy_char(alloc_policy_t alloc)
 {
 	int i;
 
--- LVM2/lib/display/display.h	2010/10/25 13:54:29	1.23
+++ LVM2/lib/display/display.h	2011/03/01 20:17:56	1.24
@@ -57,7 +57,7 @@
  * Allocation policy display conversion routines.
  */
 const char *get_alloc_string(alloc_policy_t alloc);
-const char alloc_policy_char(alloc_policy_t alloc);
+char alloc_policy_char(alloc_policy_t alloc);
 alloc_policy_t get_alloc_from_string(const char *str);
 
 char yes_no_prompt(const char *prompt, ...) __attribute__ ((format(printf, 1, 2)));


