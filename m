From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:49 -0500
Subject: master - vdo: man documenting resize
Message-ID: <201901211155.x0LBtndp024548@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01cbdc4e673989c4d432e6bea8cde1f8f9e8cda5
Commit:        01cbdc4e673989c4d432e6bea8cde1f8f9e8cda5
Parent:        a16d914d34fff420c663ba34ac8dabfc4403de51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 18 20:28:35 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: man documenting resize

---
 man/lvmvdo.7_main |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index e789f7f..11ca3ac 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -219,6 +219,42 @@ Note: vdostats currently understands only /dev/mapper device names.
 
 .fi
 
+.SS 4. Extending VDOPoolLV size
+
+Adding more space to hold VDO data and metadata can be made via
+extension of VDODataLV.
+
+Note: Size of VDOPoolLV cannot be reduced.
+
+.B lvextend -L+AddingSize VG/VDOPoolLV
+
+.I Example
+.br
+.nf
+# lvextend -L+50G vg/vdopool0
+# lvresize -L300G vg/vdopool1
+.fi
+
+.SS 4. Extending or reducing VDOLV size
+
+VDO LV can be extended or reduced as standard LV.
+
+Note: Reduction needs to process TRIM for reduced disk area
+to unmap used data blocks from VDOPoolLV and it may take
+a long time.
+
+.B lvextend -L+AddingSize VG/VDOLV
+.B lvreduce -L-ReducingSize VG/VDOLV
+
+.I Example
+.br
+.nf
+# lvextend -L+50G vg/vdo0
+# lvreduce -L-50G vg/vdo1
+# lvresize -L200G vg/vdo2
+.fi
+
+
 .SH VDO Topics
 
 .br


