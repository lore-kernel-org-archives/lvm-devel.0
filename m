From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 13:51:10 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20110919135110.31100.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 13:51:10

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Support different PATH setting
	
	When fsadm is test - it needs to execute lvm and fsadm from non-standard path
	setting.   So adding a support in fsadm script when user set LVM_BINARY, then
	the lvm command invoced from fsadm will have the same PATH setting as before
	entering  fsadm command.
	
	Needed for testing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2119&r2=1.2120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2011/09/19 13:47:37	1.2119
+++ LVM2/WHATS_NEW	2011/09/19 13:51:09	1.2120
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Support different PATH setting for fsadm script testing.
   Surround all executed commands with quotes in fsadm script.
   Fix missing '$' in test for content of "$LVM" in fsadm script.
   Move debug message in exec_cmd after sync_local_dev_names.
--- LVM2/scripts/fsadm.sh	2011/09/19 13:47:38	1.26
+++ LVM2/scripts/fsadm.sh	2011/09/19 13:51:10	1.27
@@ -31,6 +31,7 @@
 
 TOOL=fsadm
 
+_SAVEPATH=$PATH
 PATH=/sbin:/usr/sbin:/bin:/usr/sbin:$PATH
 
 # utilities
@@ -140,9 +141,10 @@
 		_FSADM_YES=$YES
 		export _FSADM_YES
 		unset FSADM_RUNNING
+		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
 		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
 	fi
-        
+
 	# error exit status for break
 	exit ${1:-1}
 }


