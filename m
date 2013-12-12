From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Dec 2013 14:03:22 +0000 (UTC)
Subject: master - man: -Z zeroes 4KiB, not just 1KiB
Message-ID: <20131212140322.C2C4560E5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3eed0aa7dca9c1895bbf80e1585debf9bddac5a8
Commit:        3eed0aa7dca9c1895bbf80e1585debf9bddac5a8
Parent:        131693c42143505f969821b7f2cab0bff471c620
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 12 10:01:37 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 12 15:02:12 2013 +0100

man: -Z zeroes 4KiB, not just 1KiB

---
 man/lvconvert.8.in |    2 +-
 man/lvcreate.8.in  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 30e9809..44b89af 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -244,7 +244,7 @@ kernel and passed down to the Physical Volume.
 Default is \fIpassdown\fP.
 .TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
-Controls zeroing of the first KB of data in the snapshot.
+Controls zeroing of the first 4KiB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
 For thin pool volumes it controls zeroing of provisioned blocks.
 Note: Provisioning of large zeroed chunks impacts performance.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 08cc15c..4a769cb 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -417,7 +417,7 @@ signatures are detected only in this case).
 Logical Volume is not wiped if the read only flag is set.
 .TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
-Controls zeroing of the first KiB of data in the new logical volume.
+Controls zeroing of the first 4KiB of data in the new logical volume.
 .br
 Default is \fIy\fPes.
 .br


