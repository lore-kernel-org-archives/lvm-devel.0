From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Jun 2011 09:24:59 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdm-deptree.c
Message-ID: <20110630092459.21613.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-30 09:24:59

Modified files:
	.              : WHATS_NEW 
	libdm          : libdm-deptree.c 

Log message:
	Report internal error when parameters are missing on table load
	
	When some target is passing empty parameters to some dm target,
	report this as an internal error to better catch some broken
	table construction (some mirror conversions seem to be doing
	this for now).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2032&r2=1.2033
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2011/06/30 09:15:53	1.2032
+++ LVM2/WHATS_NEW	2011/06/30 09:24:58	1.2033
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Report internal error when parameters are missing on table load.
   Teardown any stray devices with $COMMON_PREFIX during test runs.
   Reinstate correct permissions when creating mirrors. [2.02.85]
   Append 'm' attribute to pv_attr for missing PVs.
--- LVM2/libdm/libdm-deptree.c	2011/06/27 22:38:53	1.100
+++ LVM2/libdm/libdm-deptree.c	2011/06/30 09:24:58	1.101
@@ -1754,6 +1754,10 @@
 			stack;
 			return r;
 		}
+		if (!params[0])
+			log_error(INTERNAL_ERROR "Empty parameters for "
+				  "%s %u:%u.", dm_segtypes[seg->type].target,
+				  major, minor);
 		break;
 	}
 


