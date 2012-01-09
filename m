From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Jan 2012 12:31:53 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20120109123153.1556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-09 12:31:53

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Check for error code in _adjust_policy_params
	
	If error is detected in _adjust_policy_params, break further command processing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2217&r2=1.2218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/WHATS_NEW	2012/01/05 15:38:18	1.2217
+++ LVM2/WHATS_NEW	2012/01/09 12:31:52	1.2218
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add check for error in _adjust_policy_params() (lvextend --use-policies).
   Supports rounding of percentage (%LV, %VG...) for LV resize upward.
   Use dmeventd_lvm2_command in dmeventd plugins snapshot, raid, mirror.
   Add helper dmeventd_lvm2_command() into libdevmapper-event-lvm2 library.
--- LVM2/tools/lvresize.c	2012/01/05 15:38:19	1.146
+++ LVM2/tools/lvresize.c	2012/01/09 12:31:53	1.147
@@ -421,7 +421,8 @@
 			log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
 			return ECMD_FAILED;
 		}
-		_adjust_policy_params(cmd, lv, lp);
+		if (!_adjust_policy_params(cmd, lv, lp))
+			return ECMD_FAILED;
 	}
 
 	if (!lv_is_visible(lv)) {


