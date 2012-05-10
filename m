From: agk@sourceware.org <agk@sourceware.org>
Date: 10 May 2012 00:18:49 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20120510001849.23950.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-10 00:18:49

Modified files:
	doc            : example.conf.in 

Log message:
	Uncomment allocation section to match style of rest of file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/doc/example.conf.in	2012/04/27 18:37:42	1.48
+++ LVM2/doc/example.conf.in	2012/05/10 00:18:49	1.49
@@ -190,40 +190,38 @@
 
 # This section allows you to configure the way in which LVM selects
 # free space for its Logical Volumes.
-#allocation {
-#    When searching for free space to extend an LV, the "cling"
-#    allocation policy will choose space on the same PVs as the last
-#    segment of the existing LV.  If there is insufficient space and a
-#    list of tags is defined here, it will check whether any of them are
-#    attached to the PVs concerned and then seek to match those PV tags
-#    between existing extents and new extents.
-#    Use the special tag "@*" as a wildcard to match any PV tag.
-#    
-#    Example: LVs are mirrored between two sites within a single VG.
-#    PVs are tagged with either @site1 or @site2 to indicate where
-#    they are situated.
-#
-#    cling_tag_list = [ "@site1", "@site2" ]
-#    cling_tag_list = [ "@*" ]
-#
-#    Changes made in version 2.02.85 extended the reach of the 'cling'
-#    policies to detect more situations where data can be grouped
-#    onto the same disks.  Set this to 0 to revert to the previous
-#    algorithm.
-#
-#    maximise_cling = 1
-#
-#    Set to 1 to guarantee that mirror logs will always be placed on 
-#    different PVs from the mirror images.  This was the default
-#    until version 2.02.85.
-#
-#    mirror_logs_require_separate_pvs = 0
-#
-#    Set to 1 to guarantee that thin pool metadata will always
-#    be placed on different PVs from the pool data.
-#
-#    thin_pool_metadata_require_separate_pvs = 0
-#}
+allocation {
+
+    # When searching for free space to extend an LV, the "cling"
+    # allocation policy will choose space on the same PVs as the last
+    # segment of the existing LV.  If there is insufficient space and a
+    # list of tags is defined here, it will check whether any of them are
+    # attached to the PVs concerned and then seek to match those PV tags
+    # between existing extents and new extents.
+    # Use the special tag "@*" as a wildcard to match any PV tag.
+ 
+    # Example: LVs are mirrored between two sites within a single VG.
+    # PVs are tagged with either @site1 or @site2 to indicate where
+    # they are situated.
+
+    # cling_tag_list = [ "@site1", "@site2" ]
+    # cling_tag_list = [ "@*" ]
+
+    # Changes made in version 2.02.85 extended the reach of the 'cling'
+    # policies to detect more situations where data can be grouped
+    # onto the same disks.  Set this to 0 to revert to the previous
+    # algorithm.
+    maximise_cling = 1
+
+    # Set to 1 to guarantee that mirror logs will always be placed on 
+    # different PVs from the mirror images.  This was the default
+    # until version 2.02.85.
+    mirror_logs_require_separate_pvs = 0
+
+    # Set to 1 to guarantee that thin pool metadata will always
+    # be placed on different PVs from the pool data.
+    thin_pool_metadata_require_separate_pvs = 0
+}
 
 # This section that allows you to configure the nature of the
 # information that LVM2 reports.


