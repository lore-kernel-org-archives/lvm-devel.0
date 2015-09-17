From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 17 Sep 2015 12:36:50 +0000 (UTC)
Subject: master - WHATS_NEW: commit 6c0b4a2769067048fa144814e298a3272564c475
Message-ID: <20150917123650.D25DC60C3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bc8c713e2d25d5b4b3d2ba827905aecf378f721
Commit:        5bc8c713e2d25d5b4b3d2ba827905aecf378f721
Parent:        6c0b4a2769067048fa144814e298a3272564c475
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 17 14:36:39 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 17 14:36:39 2015 +0200

WHATS_NEW: commit 6c0b4a2769067048fa144814e298a3272564c475

---
 WHATS_NEW_DM |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b519fd5..c6250a6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Check dir path components are valid if using dm_create_dir, error out if not.
   Fix /dev/mapper handling to remove dangling entries if symlinks are found.
   Make it possible to use blank value as selection for string list report field.
 


