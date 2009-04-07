From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Apr 2009 22:53:49 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20090407225349.16007.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-04-07 22:53:48

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Add missing 'device-mapper' internal subdir build dependency.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1077&r2=1.1078
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2009/04/07 10:20:28	1.1077
+++ LVM2/WHATS_NEW	2009/04/07 22:53:48	1.1078
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add missing 'device-mapper' internal subdir build dependency.
   Fix memory leak in mirror allocation code.
   Save and restore the previous logging level when log level is changed.
   Fix error message when archive initialization fails.
--- LVM2/make.tmpl.in	2009/02/22 22:11:58	1.64
+++ LVM2/make.tmpl.in	2009/04/07 22:53:48	1.65
@@ -152,7 +152,7 @@
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
 
-$(SUBDIRS):
+$(SUBDIRS): $(SUBDIRS.device-mapper)
 	$(MAKE) -C $@
 
 $(SUBDIRS.device-mapper):


