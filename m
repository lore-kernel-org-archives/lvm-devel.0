From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Aug 2010 12:57:04 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20100802125704.15825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-02 12:57:04

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	revert the 'Base' change - that wasn't the cause of the problem

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1683&r2=1.1684
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2010/08/02 12:44:21	1.1683
+++ LVM2/WHATS_NEW	2010/08/02 12:57:04	1.1684
@@ -3,7 +3,6 @@
   Fix exported_symbols generation to use standard compiler arguments.
   Use #include <> not "" in lvm2app.h which gets installed on the system.
   Make liblvm.device-mapper wait for include file generation.
-  Drop explicit 'Base' version from exported symbols.
   Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
   Fix wrong number of mirror log at allocate policy
 
--- LVM2/make.tmpl.in	2010/08/02 12:44:21	1.108
+++ LVM2/make.tmpl.in	2010/08/02 12:57:04	1.109
@@ -366,7 +366,7 @@
 	) > $@
 
 .export.sym: .exported_symbols_generated
-	set -e; (echo "{"; echo "	global:"; \
+	set -e; (echo "Base {"; echo "	global:"; \
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 


