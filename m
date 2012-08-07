From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:42 +0000 (UTC)
Subject: master - man: expand lvchange --discard entry
Message-ID: <20120807203042.BD7FD3454@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=597590da7412485ccdcb71ca909fbc5f73ec2aa1
Commit:        597590da7412485ccdcb71ca909fbc5f73ec2aa1
Parent:        1ca813083f34082dd32ceab6e125ef379769e21e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 20:20:16 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 20:20:16 2012 +0100

man: expand lvchange --discard entry

---
 man/lvchange.8.in |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index beb77a8..e58d79c 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -73,7 +73,12 @@ logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
 .BR \-\-discard " {" \fIignore | \fInopassdown | \fIpassdown }
-Change discard behavior.
+Set this to \fIignore\fP to ignore any discards received by a
+thin pool Logical Volume.  Set to \fInopassdown\fP to process such
+discards within the thin pool itself and allow the no-longer-needed
+extents to be overwritten by new data.  Set to \fIpassdown\fP to
+process them both within the thin pool itself and to pass them down
+the underlying device.
 .TP
 .B \-\-resync
 Forces the complete resynchronization of a mirror.  In normal


