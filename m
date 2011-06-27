From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 13:44:35 -0000
Subject: LVM2/daemons/lvmetad Makefile test.sh
Message-ID: <20110627134435.18826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 13:44:34

Modified files:
	daemons/lvmetad: Makefile 
Added files:
	daemons/lvmetad: test.sh 

Log message:
	LVMetaD build hack: link to lvm-internal &c. and add a simple test script.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/test.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.diff?cvsroot=lvm2&r1=1.1&r2=1.2

/cvs/lvm2/LVM2/daemons/lvmetad/test.sh,v  -->  standard output
revision 1.1
--- LVM2/daemons/lvmetad/test.sh
+++ -	2011-06-27 13:44:34.722209000 +0000
@@ -0,0 +1,14 @@
+#!/bin/bash
+
+export LD_LIBRARY_PATH="$1"
+
+test -n "$2" && {
+    ./lvmetad -f &
+    PID=$!
+    sleep .1
+    ./testclient
+    kill $PID
+    exit 0
+}
+
+sudo ./test.sh "$1" .
--- LVM2/daemons/lvmetad/Makefile	2011/06/14 02:36:38	1.1
+++ LVM2/daemons/lvmetad/Makefile	2011/06/27 13:44:33	1.2
@@ -13,9 +13,10 @@
 CLIENT_H = ../common/daemon-client.h $(SHARED_H)
 SERVER_H = ../common/daemon-server.h $(SHARED_H)
 
-LIBS = -ldevmapper -lpthread
+LIBS = -ldevmapper -lpthread -ldevmapper-event -llvm-internal -ldl
 IPATH = -I../common -I/srv/build/lvm2/cvs-lvmetad/default/include
-LPATH = -L/srv/build/lvm2/cvs-lvmetad/default/libdm
+BUILDDIR = /srv/build/lvm2/cvs-lvmetad/default
+LPATH = -L$(BUILDDIR)/libdm -L$(BUILDDIR)/lib -L$(BUILDDIR)/daemons/dmeventd
 
 all: testclient lvmetad
 
@@ -24,3 +25,6 @@
 
 lvmetad: lvmetad-core.c ../common/daemon-server.c ../common/daemon-server.h ../common/daemon-shared.h ../common/daemon-shared.c
 	gcc -g lvmetad-core.c $(SERVER) $(IPATH) $(LPATH) $(LIBS) -o lvmetad
+
+check: testclient lvmetad
+	./test.sh "$(BUILDDIR)/libdm:$(BUILDDIR)/daemons/dmeventd"


