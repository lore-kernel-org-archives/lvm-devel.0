From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Jul 2014 20:16:46 +0000 (UTC)
Subject: master - man: lvmthin fix line breaks
Message-ID: <20140711201646.6C975601B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e4f24115a9b5dc8f60436195bffc60100d02620
Commit:        3e4f24115a9b5dc8f60436195bffc60100d02620
Parent:        65a3f50556c3544f1145d86b1b2ddd517838a950
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 11 15:15:03 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 11 15:15:03 2014 -0500

man: lvmthin fix line breaks

The html rendering inserted some unpleasant line breaks,
so insert better breaks explicitly.
---
 man/lvmthin.7.in |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index fbd7a91..d534b42 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -662,7 +662,10 @@ of an existing thin pool LV:
 .B lvchange \-\-monitor {y|n} VG/ThinPoolLV
 
 .BR lvm.conf (5)
-.B thin_pool_autoextend_threshold thin_pool_autoextend_percent
+.B thin_pool_autoextend_threshold
+.br
+.BR lvm.conf (5)
+.B thin_pool_autoextend_percent
 .br
 control the default autoextend behavior.
 
@@ -769,7 +772,10 @@ indicated by the "z" attribute displayed by lvs.  The option \-Z
 
 Command to set the zeroing mode when creating a thin pool LV:
 .br
-.B lvconvert \-Z{y|n} \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvconvert \-Z{y|n} \-\-thinpool VG/ThinDataLV
+.br
+.B "   "  \-\-poolmetadata VG/ThinMetaLV
+
 
 Command to change the zeroing mode of an existing thin pool LV:
 .br
@@ -987,7 +993,9 @@ and creates a thin LV in the new pool.
 .br
 \-V VirtualSize specifies the virtual size of the thin LV.
 
-.B lvcreate \-L LargeSize \-V VirtualSize \-n ThinLV \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-L LargeSize \-V VirtualSize \-n ThinLV
+.br
+.B "   "  \-\-thinpool VG/ThinPoolLV
 
 Equivalent to:
 .br


