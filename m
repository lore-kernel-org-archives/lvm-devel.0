From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2012 01:28:16 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120303012816.10868.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-03 01:28:15

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2336&r2=1.2337

--- LVM2/WHATS_NEW	2012/03/03 01:00:49	1.2336
+++ LVM2/WHATS_NEW	2012/03/03 01:28:15	1.2337
@@ -28,6 +28,7 @@
   Limit sscanf parameters with buffer size in clvmd get_initial_state().
   Use const lv pointer for lv_is_active...() functions. 
   Use same signed numbers in _mirrored_transient_status().
+  Support 'pvscan --cache' to update lvmetad state from specific PVs.
   Provide new metadata daemon for testing with configure --enable-lvmetad .
   Integrate client-side lvmetad into build.
 


