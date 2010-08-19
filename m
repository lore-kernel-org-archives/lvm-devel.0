From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 20 Aug 2010 01:58:37 +0200
Subject: patch1/4: lvm manpages
Message-ID: <1282262317.3337.94.camel@fermat.scientia.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi.

Attached would be several patches, that (IMHO) improve the lvm(8) manpage:



1) lvm.8.empty_LV.patch
It seems that the current "Where a list of VGs is required but is left empty, a
list  of  all VGs will be substituted." is also true for LVs (checked it with
lvdisplay, which seems to lists all LVs).
If this is true, add the patch, to reflect this in the documentation


Cheers,
Chris.




--- lvm.8	2010-06-23 16:25:44.099108000 +0200
+++ lvm.8	2010-06-23 16:28:42.675357517 +0200
@@ -24,8 +24,8 @@
 .LP
 Where commands take VG or LV names as arguments, the full path name is
 optional.  An LV called "lvol0" in a VG called "vg0" can be specified
-as "vg0/lvol0".  Where a list of VGs is required but is left empty, 
-a list of all VGs will be substituted.  Where a list of LVs is required
+as "vg0/lvol0".  Where a list of VGs or LVs is required but left empty, 
+a list of all VGs or LVs will be substituted.  Where a list of LVs is required
 but a VG is given, a list of all the LVs in that VG will be substituted.
 So "lvdisplay vg0" will display all the LVs in "vg0".
 Tags can also be used - see \fBaddtag\fP below.


