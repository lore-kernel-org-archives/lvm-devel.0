From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Oct 2014 18:35:30 +0000 (UTC)
Subject: master - man: lvmthin show the lvcreate -n option for pools
Message-ID: <20141006183530.AFB0561112@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=902192abdc3bc8cf17c89b14db4496476e7fa73c
Commit:        902192abdc3bc8cf17c89b14db4496476e7fa73c
Parent:        1115a9ea51a3302ede188073f94a42f4b38867da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 6 13:29:18 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 6 13:29:18 2014 -0500

man: lvmthin show the lvcreate -n option for pools

lvcreate of thin pools can now use '-n lv vg' like other lv types,
or it can name the new thin pool in the free arg as 'vg/lv', which
is not allowed with other lv types.
---
 man/lvmthin.7.in |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 8009a9e..84a3138 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -989,16 +989,12 @@ rather than using lvconvert on existing LVs.
 This one command creates a thin data LV, a thin metadata LV,
 and combines the two into a thin pool LV.
 
-.B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
-
-./" FIXME: make this work
-./" or using standard form of lvcreate:
-./" .B lvcreate \-\-type thin\-pool \-L LargeSize \-n ThinPoolLV VG
+.B lvcreate \-\-type thin\-pool \-L LargeSize \-n ThinPoolLV VG
 
 .I Example
 .br
 .nf
-# lvcreate \-\-type thin\-pool \-L8M vg/pool0
+# lvcreate \-\-type thin\-pool \-L8M -n pool0 vg
 
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%


