From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 10 Feb 2010 18:53:41 -0500 (EST)
Subject: [PATCH] fix build of snapshot dmeventd module
Message-ID: <Pine.LNX.4.64.1002101833590.15802@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix build of snapshot dmeventd module

When you type "make", the module is not compiled. It is compiled on
"make install" command.

The reason is that "make" without arguments takes the first target,
that is "mirror", it depends on "lvm2", thus it builds only "lvm2" and "mirror"
subdirectories, but not "snapshot".

The patch changes Makefile so that make.tmpl is included before individual
targets, make.tmpl contains "all" as its first target, so simple "make" command
will build all the subdirectories.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 daemons/dmeventd/plugins/Makefile.in |    5 ++---
 2 files changed, 4 insertions(+), 6 deletions(-)

Index: LVM2.2.02.60/daemons/dmeventd/plugins/Makefile.in
===================================================================
--- LVM2.2.02.60.orig/daemons/dmeventd/plugins/Makefile.in	2010-02-10 23:20:02.000000000 +0100
+++ LVM2.2.02.60/daemons/dmeventd/plugins/Makefile.in	2010-02-10 23:20:11.000000000 +0100
@@ -19,8 +19,7 @@ VPATH = @srcdir@
 
 SUBDIRS += lvm2 mirror snapshot
 
-mirror: lvm2
-snapshot: lvm2
-
 include ../../../make.tmpl
 
+mirror: lvm2
+snapshot: lvm2


