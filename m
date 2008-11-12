From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2008 09:41:45 -0000
Subject: LVM2/lib/misc lvm-globals.h
Message-ID: <20081112094145.18337.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-11-12 09:41:45

Modified files:
	lib/misc       : lvm-globals.h 

Log message:
	removed redundant redeclaration of init_indent() and init_msg_prefix() from lvm-logging.h

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/misc/lvm-globals.h	2008/11/03 18:59:58	1.2
+++ LVM2/lib/misc/lvm-globals.h	2008/11/12 09:41:44	1.3
@@ -27,8 +27,6 @@
 void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_cmd_name(int status);
-void init_msg_prefix(const char *prefix);
-void init_indent(int indent);
 void init_ignorelockingfailure(int level);
 void init_lockingfailed(int level);
 void init_security_level(int level);


