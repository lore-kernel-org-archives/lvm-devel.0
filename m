From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 21 Jul 2014 15:29:56 +0000 (UTC)
Subject: master - man: use macros for indenting in lvmthin
Message-ID: <20140721152956.8249760F41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1fe487043dadf189b08b9862f45d21438f197cf2
Commit:        1fe487043dadf189b08b9862f45d21438f197cf2
Parent:        3366baf07675a259eeb7828fb6e605108a5a4290
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 21 10:28:20 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 21 10:28:20 2014 -0500

man: use macros for indenting in lvmthin

---
 man/lvmthin.7.in |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index d534b42..6652f7e 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -818,7 +818,9 @@ Command to set the discard mode when creating a thin pool LV:
 .br
 .B lvconvert \-\-discards {ignore|nopassdown|passdown}
 .br
-.B "   "  \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.RS
+.B \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.RE
 
 Command to change the discard mode of an existing thin pool LV:
 .br
@@ -933,7 +935,9 @@ name of ExampleLV.
 
 .B lvconvert \-\-type thin \-\-thinpool VG/ThinPoolLV
 .br
-.B "    " \-\-originname NewExternalOriginLV \-\-thin VG/ExampleLV
+.RS
+.B \-\-originname NewExternalOriginLV \-\-thin VG/ExampleLV
+.RE
 
 .I Example
 .br


