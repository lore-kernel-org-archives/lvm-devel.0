From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 15 Jul 2016 20:08:15 +0000 (UTC)
Subject: master - man: drop lvmraid references from lvconvert
Message-ID: <20160715200815.33B6860DF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=081e569e14cbf3f3c73aedf0e107b8b3a2c69455
Commit:        081e569e14cbf3f3c73aedf0e107b8b3a2c69455
Parent:        e96d1ad3efea51448f0cdd39e7c84db05d3c6cbf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 15 15:08:02 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 15 15:08:02 2016 -0500

man: drop lvmraid references from lvconvert

---
 man/lvconvert.8.in |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 5f15f34..95f7095 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -205,9 +205,6 @@ The
 type refers to one of many raid levels, e.g.
 .B raid1,
 .B raid5.
-See
-.BR lvmraid (7)
-for a full list.
 
 .SS LV layers
 
@@ -328,7 +325,7 @@ VG/StripedLV
 Convert StripedLV to type raid*.
 .br
 \[bu]
-Required options depend on the raid level, see lvmraid(7).
+Required options depend on the raid level.
 
 .SS Operations on RaidLV with type raid*:
 
@@ -453,7 +450,7 @@ VG/RaidLV
 Convert RaidLV to use a different raid level.
 .br
 \[bu]
-Required options depend on the raid level, see lvmraid(7).
+Required options depend on the raid level.
 
 .B lvconvert \-\-type striped
 VG/RaidLV
@@ -514,7 +511,7 @@ VG/MirrorLV
 Convert MirrorLV to type raid*.
 .br
 \[bu]
-Required options depend on the raid level, see lvmraid(7).
+Required options depend on the raid level.
 
 .SS Operations on CachePoolLV with type cache\-pool:
 
@@ -918,8 +915,6 @@ Use \fB\-f\fP if you do not want any replacement.  You may use
 \fB\-\-use\-policies\fP to use the device replacement policy specified in
 \fBlvm.conf\fP(5), see \fBactivation/mirror_log_fault_policy\fP or
 \fBactivation/mirror_device_fault_policy\fP.
-Also see
-.BR lvmraid (7).
 
 When used with a thin pool LV, this option automates the use of the
 \fBthin_repair\fP(8) tool on the thin pool.  This repairs a very limitted
@@ -937,10 +932,7 @@ Also see
 Remove the specified device \fIPhysicalVolume\fP and replace it with one
 that is available in the VG, or from a specific list of PVs specified on
 the command line following the LV name. This option may be repeated multiple
-times depending on the RaidLV type.  See
-.BR lvmraid (7)
-for specific limits on device replacement for each raid level.
-(This option only applies to \fBraid*\fP LV types.)
+times depending on the RaidLV type.
 .
 .HP
 .BR \-s ,


