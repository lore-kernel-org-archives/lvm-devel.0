From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat, 10 Dec 2016 12:22:15 +0000 (UTC)
Subject: master - doc: add filemap creation fixes to WHATS_NEW_DM
Message-ID: <20161210122215.B009360CE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1de3e106c96f6df7b32e072b6a1a3f924fa041bc
Commit:        1de3e106c96f6df7b32e072b6a1a3f924fa041bc
Parent:        2d1dbb9eddd9dbc3aedf4572926178e532899995
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 10 12:02:30 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 12:02:30 2016 +0000

doc: add filemap creation fixes to WHATS_NEW_DM

---
 WHATS_NEW_DM |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c6a4902..4113876 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,8 @@
 Version 1.02.138 - 
 =====================================
+  Fix segmentation fault when filemap region creation fails
+  Fix performance of region cleanup for failed filemap creation.
+  Fix very slow region deletion with many regions.
 
 Version 1.02.137 - 30th November 2016
 =====================================


