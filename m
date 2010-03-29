From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:22:04 -0000
Subject: LVM2/man Makefile.in
Message-ID: <20100329142204.22415.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:22:00

Modified files:
	man            : Makefile.in 

Log message:
	Avoid modification of .in files outside man directory.
	(i.e. this rule actually tried to change ../make.tmpl in some cases and
	left this file completely broken)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/man/Makefile.in	2010/03/29 14:18:01	1.33
+++ LVM2/man/Makefile.in	2010/03/29 14:22:00	1.34
@@ -66,7 +66,10 @@
 $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
 
 %: %.in
-	$(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@
+	@case "$@" in \
+	  */*) ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@ ;; \
+	esac
 
 install_lvm2:
 	@echo "Installing $(MAN8) in $(MAN8DIR)"


