From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2011 12:39:46 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111104123946.9573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-04 12:39:45

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Thin fix condition check for transation_id
	
	id2 must be checked.
	(missed in yesterday commit set).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/libdm/libdm-deptree.c	2011/11/03 14:45:01	1.144
+++ LVM2/libdm/libdm-deptree.c	2011/11/04 12:39:45	1.145
@@ -2980,11 +2980,11 @@
 		tm->message.u.m_trim.new_size = id2;
 		break;
 	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
-		if ((id1 + 1) !=  id2) {
+		if ((id1 + 1) != id2) {
 			log_error("New transaction id must be sequential.");
 			return 0; /* FIXME: Maybe too strict here? */
 		}
-		if (id1 !=  seg->transaction_id) {
+		if (id2 != seg->transaction_id) {
 			log_error("Current transaction id is different from thin pool.");
 			return 0; /* FIXME: Maybe too strict here? */
 		}


