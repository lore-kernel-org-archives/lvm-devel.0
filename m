From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 27 Jul 2016 18:15:47 +0000 (UTC)
Subject: master - man: lvmthin clean up syntax example
Message-ID: <20160727181547.F145661C94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17fb64b569742a2d247f20d198a8b6facdd12a0c
Commit:        17fb64b569742a2d247f20d198a8b6facdd12a0c
Parent:        c7b2654c25b8953c55638e7fab2cd0268845cbb3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 27 13:13:59 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 27 13:13:59 2016 -0500

man: lvmthin clean up syntax example

The syntax for converting an LV to a thin LV
included an unnecessary --thin option.  I was
probably still confused about these options
when writing this.
---
 man/lvmthin.7.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index c142f56..ce86974 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -1173,7 +1173,7 @@ name of ExampleLV.
 .B lvconvert \-\-type thin \-\-thinpool VG/ThinPoolLV
 .br
 .RS
-.B \-\-originname NewExternalOriginLV \-\-thin VG/ExampleLV
+.B \-\-originname NewExternalOriginLV VG/ExampleLV
 .RE
 
 .I Example


