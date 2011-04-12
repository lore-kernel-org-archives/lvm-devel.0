From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 12 Apr 2011 20:44:42 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20110412204442.10134.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-04-12 20:44:42

Modified files:
	doc            : example.conf.in 

Log message:
	fix s/then/than/ typos in 'pv_min_size' section and fold floppy example
	into documentation preamble.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/doc/example.conf.in	2011/02/27 00:38:32	1.19
+++ LVM2/doc/example.conf.in	2011/04/12 20:44:41	1.20
@@ -147,11 +147,10 @@
 
     # Minimal size (in KB) of the block device which can be used as a PV.
     # In clustered environment all nodes have to use the same value.
-    # Any value smaller then 512KB is ignored.
-    pv_min_size = 512
-
-    # Example: Ignore devices smaller then 2MB (i.e. floppy drives).
+    # Any value smaller than 512KB is ignored.
+    # Example: Ignore devices smaller than 2MB (i.e. floppy drives).
     # pv_min_size = 2048
+    pv_min_size = 512
 }
 
 # This section allows you to configure the way in which LVM selects


