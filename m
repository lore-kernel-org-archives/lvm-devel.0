From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2010 10:44:31 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100728104431.6788.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-28 10:44:30

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.397&r2=1.398

--- LVM2/WHATS_NEW_DM	2010/07/27 22:52:19	1.397
+++ LVM2/WHATS_NEW_DM	2010/07/28 10:44:29	1.398
@@ -1,5 +1,6 @@
 Version 1.02.53 - 27th July 2010
 ================================
+  Revert failed table load preparation after "create, load and resume".
   Switch dmeventd to use dm_create_lockfile and drop duplicate code.
   Add dm_create_lockfile to libdm to handle pidfiles for all daemons.
   Replace lookup with next in struct dfa_state & calculate states on demand.


