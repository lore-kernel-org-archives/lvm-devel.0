From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:41:16 -0500
Subject: master - man: lvmvdo component activation description
Message-ID: <201901282141.x0SLfGi7002807@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5cf8888976118cfbc44da28462ebaf9aae3927d7
Commit:        5cf8888976118cfbc44da28462ebaf9aae3927d7
Parent:        d04520c321cc33b2874c3f09d126602cb714a9ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 16:12:04 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:39:10 2019 +0100

man: lvmvdo component activation description

Describe component activation for VDO Data LV.
---
 man/lvmvdo.7_main |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index ae507df..2572b46 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -260,6 +260,21 @@ a long time.
 # lvresize -L200G vg/vdo2
 .fi
 
+.SS 5. Component activation of VDODataLV
+
+VDODataLV can be activated separately as component LV for examination
+purposes. It activates data LV in read-only mode and cannot be modified.
+If the VDODataLV is active as component, any upper LV using this volume CANNOT
+be activated. User has to deactivate VDODataLV first to continue to use VDOPoolLV.
+
+.I Example
+.br
+.nf
+# lvchange -ay vg/vpool0_vdata
+# lvchange -an vg/vpool0_vdata
+.fi
+
+
 .SH VDO Topics
 .br
 


