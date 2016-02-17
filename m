From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Feb 2016 14:38:44 +0000 (UTC)
Subject: master - man: fix list of restricted LV name suffixes
Message-ID: <20160217143844.F3D0460C94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=055c628e38589bf1ea66bc0b2c5da36ed115b551
Commit:        055c628e38589bf1ea66bc0b2c5da36ed115b551
Parent:        065526c59084d3d47de476acee2d095199e9412d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 17 15:38:27 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 17 15:38:27 2016 +0100

man: fix list of restricted LV name suffixes

---
 man/lvm.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 4f801c9..fe30b75 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -489,7 +489,7 @@ not be used as LV or VG names. A VG cannot be called anything that exists in
 An LV cannot be called '.', '..', 'snapshot' or 'pvmove'.
 The LV name may also not contain any of the following strings:
 \fR'_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare',
-\fR'_rimage', '_rlog', '_tdata' or '_tmeta'.
+\fR'_rimage', '_rmeta', '_tdata', '_tmeta' or '_vorigin'.
 A directory bearing the name of each Volume Group is created under
 \fI/dev\fP when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic


