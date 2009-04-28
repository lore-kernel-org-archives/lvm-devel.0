From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Apr 2009 19:08:26 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20090428190826.26289.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-28 19:08:25

Modified files:
	test/api       : Makefile.in 

Log message:
	Use liblvm.so instead of .a

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/api/Makefile.in	2009/04/20 20:46:06	1.4
+++ LVM2/test/api/Makefile.in	2009/04/28 19:08:25	1.5
@@ -35,6 +35,6 @@
 LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 CLDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 
-test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm.a $(top_srcdir)/libdm/libdevmapper.so
+test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm.so $(top_srcdir)/libdm/libdevmapper.so
 	$(CC) -o test $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
 


