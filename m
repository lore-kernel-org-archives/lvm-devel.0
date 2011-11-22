From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Nov 2011 13:54:06 -0000
Subject: LVM2/doc tagging.txt
Message-ID: <20111122135406.7067.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-11-22 13:54:05

Modified files:
	doc            : tagging.txt 

Log message:
	--addtag instead of --tag

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/tagging.txt.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/doc/tagging.txt	2004/11/17 18:34:49	1.1
+++ LVM2/doc/tagging.txt	2011/11/22 13:54:05	1.2
@@ -85,7 +85,7 @@
   From any machine in the cluster, add db1 to the list of machines that
   activate vg1/lvol2:
 
-  lvchange --tag @db1 vg1/lvol2
+  lvchange --addtag @db1 vg1/lvol2
   (followed by lvchange -ay to actually activate it)
 
 
@@ -98,10 +98,10 @@
 
   Option (i) - centralised admin, static configuration replicated between hosts  
     # Add @database tag to vg1's metadata
-    vgchange --tag @database vg1
+    vgchange --addtag @database vg1
 
     # Add @fileserver tag to vg2's metadata
-    vgchange --tag @fileserver vg2
+    vgchange --addtag @fileserver vg2
 
     lvm.conf:  (Identical on every machine)
       tags {
@@ -122,17 +122,17 @@
       }
   
   In the event of the fileserver host going down, vg2 can be brought up
-  on fsb1 by running *on any node* 'vgchange --tag @fileserverbackup vg2'
+  on fsb1 by running *on any node* 'vgchange --addtag @fileserverbackup vg2'
   followed by 'vgchange -ay vg2'
   
   
   Option (ii) - localised admin & configuation
   (i.e. each host holds *locally* which classes of volumes to activate)
     # Add @database tag to vg1's metadata
-    vgchange --tag @database vg1
+    vgchange --addtag @database vg1
   
     # Add @fileserver tag to vg2's metadata
-    vgchange --tag @fileserver vg2
+    vgchange --addtag @fileserver vg2
   
     lvm.conf:  (Identical on every machine - global settings)
       tags {


