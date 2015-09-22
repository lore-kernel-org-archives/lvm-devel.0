From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 22 Sep 2015 18:45:09 +0000 (UTC)
Subject: master - man lvmthin: use --poolmetadatasize option
Message-ID: <20150922184509.4833460D33@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=532b2d2d4e6817b8971665c2fe30821c7ec7dadd
Commit:        532b2d2d4e6817b8971665c2fe30821c7ec7dadd
Parent:        214e2cddf639e4b5a610e34ac24dbe2fd4618fb6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 22 13:44:09 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 22 13:44:09 2015 -0500

man lvmthin: use --poolmetadatasize option

when extending a pool metadata lv, rather than
referencing the _tmeta device.
---
 man/lvmthin.7.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index eb791f0..c142f56 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -583,7 +583,7 @@ with the lvs \-o+metadata_percent command.
 
 Command to extend thin pool metadata space:
 .br
-.B lvextend \-L Size VG/ThinPoolLV_tmeta
+.B lvextend \-\-poolmetadatasize Size VG/ThinPoolLV
 
 .I Example
 .br
@@ -605,7 +605,7 @@ Command to extend thin pool metadata space:
 
 3. Double the amount of physical space in the thin metadata LV.
 .nf
-# lvextend \-L+12M vg/pool0_tmeta
+# lvextend \-\-poolmetadatasize +12M vg/pool0
 .fi
 
 4. The percentage of used metadata blocks is half the previous value.
@@ -873,7 +873,7 @@ repair.
 .br
    See "Metadata check and repair".
 
-3. Extend pool metadata space with lvextend VG/ThinPoolLV_tmeta.
+3. Extend pool metadata space with lvextend \-\-poolmetadatasize.
 .br
    See "Manually manage free metadata space of a thin pool LV".
 


