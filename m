From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 24 May 2018 07:23:24 -0400
Subject: master - release note: 2.02.178
Message-ID: <201805241123.w4OBNOUU018848@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9337ff48bcf5ed60a06c8cea8daafc855653e493
Commit:        9337ff48bcf5ed60a06c8cea8daafc855653e493
Parent:        a90de76fd8502644e8b42daf88fe055c82fb2abc
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 24 12:18:03 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 24 12:22:11 2018 +0100

release note: 2.02.178

---
 doc/release-notes/2.02.178 |   53 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/doc/release-notes/2.02.178 b/doc/release-notes/2.02.178
new file mode 100644
index 0000000..3a53eab
--- /dev/null
+++ b/doc/release-notes/2.02.178
@@ -0,0 +1,53 @@
+Version 2.02.178
+================
+
+There are going to be some large changes to the lvm2 codebase
+over the next year or so.  Starting with this release.  These
+changes should be internal rather than having a big effect on
+the command line.  Inevitably these changes will increase the
+chance of bugs, so please be on the alert.
+
+
+Remove support for obsolete metadata formats
+--------------------------------------------
+
+Support for the GFS pool format, and format used by the
+original 1990's version of LVM1 have been removed.
+
+Use asynchronous IO
+-------------------
+
+Almost all IO uses libaio now.
+
+Rewrite label scanning
+----------------------
+
+Dave Tiegland has reworked the label scanning and metadata reading
+logic to minimise the amount a IOs issued.  Combined with the aio changes 
+this can greatly improve scanning speed for some systems.
+
+./configure options
+-------------------
+
+We're going to try and remove as many options from ./configure as we
+can.  Each option multiplies the number of possible configurations
+that we should test (this testing is currently not occuring).
+
+The first batch to be removed are:
+
+  --enable-testing switch for ./configure has been removed.
+  --with-snapshots switch for ./configure has been removed.
+  --with-mirrors switch for ./configure has been removed.
+  --with-raid switch for ./configure has been removed.
+  --with-thin switch for ./configure has been removed.
+  --with-cache switch for ./configure has been removed.
+
+Stable targets that are in the upstream kernel will just be supported.
+
+In future optional target flags will be given in two situations:
+
+1) The target is experimental, or not upstream at all (eg, vdo).
+2) The target is deprecated and support will be removed at some future date.
+
+This decision could well be contentious, so could distro maintainers feel
+free to comment.


