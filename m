From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Oct 2011 20:49:25 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in
Message-ID: <20111004204925.15246.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-10-04 20:49:24

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 

Log message:
	Clarify multi-name device filter pattern matching explanation in lvm.conf.5.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2144&r2=1.2145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2011/10/03 18:37:47	1.2144
+++ LVM2/WHATS_NEW	2011/10/04 20:49:24	1.2145
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Clarify multi-name device filter pattern matching explanation in lvm.conf.5.
   Introduce lv_send_message and dev_manager_send_message.
   Introduce revert_lv for better pvmove cleanup.
   Replace incomplete pvmove activation failure recovery code with a message.
--- LVM2/doc/example.conf.in	2011/09/22 17:39:57	1.32
+++ LVM2/doc/example.conf.in	2011/10/04 20:49:24	1.33
@@ -51,9 +51,11 @@
 
     # Be careful if there there are symbolic links or multiple filesystem 
     # entries for the same device as each name is checked separately against
-    # the list of patterns.  The effect is that if any name matches any 'a'
-    # pattern, the device is accepted; otherwise if any name matches any 'r'
-    # pattern it is rejected; otherwise it is accepted.
+    # the list of patterns.  The effect is that if the first pattern in the 
+    # list to match a name is an 'a' pattern for any of the names, the device
+    # is accepted; otherwise if the first pattern in the list to match a name
+    # is an 'r' pattern for any of the names it is rejected; otherwise it is
+    # accepted.
 
     # Don't have more than one filter line active at once: only one gets used.
 


