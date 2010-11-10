From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2010 10:05:27 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101110100527.4817.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-10 10:05:27

Modified files:
	.              : WHATS_NEW 

Log message:
	Update fsadm regresion

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1793&r2=1.1794

--- LVM2/WHATS_NEW	2010/11/09 12:34:40	1.1793
+++ LVM2/WHATS_NEW	2010/11/10 10:05:27	1.1794
@@ -1,5 +1,6 @@
 Version 2.02.77 -
 ===================================
+  Fix regression in detection of mounted filesystem for older systems (2.0.75).
   Extend cling allocation policy to recognise PV tags (cling_by_tags).
   Add allocation/cling_tag_list to lvm.conf.
   Regenerate configure with 'autoreconf' for --enable-ocf. (2.02.76)


