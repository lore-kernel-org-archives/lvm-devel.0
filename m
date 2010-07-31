From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2010 14:14:00 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20100731141400.16913.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-31 14:13:59

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Drop explicit 'Base' version from exported symbols.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1679&r2=1.1680
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW	2010/07/31 00:43:41	1.1679
+++ LVM2/WHATS_NEW	2010/07/31 14:13:59	1.1680
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Drop explicit 'Base' version from exported symbols.
   Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
   Fix wrong number of mirror log at allocate policy
 
--- LVM2/make.tmpl.in	2010/07/20 14:38:44	1.106
+++ LVM2/make.tmpl.in	2010/07/31 14:13:59	1.107
@@ -366,7 +366,7 @@
 	) > $@
 
 .export.sym: .exported_symbols_generated
-	set -e; (echo "Base {"; echo "	global:"; \
+	set -e; (echo "{"; echo "	global:"; \
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 


