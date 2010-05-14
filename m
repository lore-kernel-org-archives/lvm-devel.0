From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 May 2010 13:32:36 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20100514133236.1235.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-14 13:32:36

Modified files:
	.              : make.tmpl.in 

Log message:
	For lcov target there is no need to include source file dependencies

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/make.tmpl.in	2010/05/11 08:57:02	1.97
+++ LVM2/make.tmpl.in	2010/05/14 13:32:36	1.98
@@ -350,7 +350,7 @@
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean))
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov))
     ifdef SOURCES
        -include $(SOURCES:.c=.d)
     endif


