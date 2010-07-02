From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Jul 2010 17:44:18 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100702174418.14692.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-07-02 17:44:17

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1649&r2=1.1650

--- LVM2/WHATS_NEW	2010/07/02 02:09:57	1.1649
+++ LVM2/WHATS_NEW	2010/07/02 17:44:17	1.1650
@@ -7,6 +7,7 @@
   Fix lvm shell crash when input is entirely whitespace.
   Update partial mode warning message.
   Preserve memlock balance in clvmd when activation triggers a resume.
+  Restore the "removemissing" behaviour of lvconvert --repair --use-policies.
 
 Version 2.02.69 - 30th June 2010
 ================================


