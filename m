From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:42 +0000 (UTC)
Subject: master - example.conf.in: The command to refresh lvmetad is pvscan --cache.
Message-ID: <20120926175542.99270A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ceb79c9a500f38ac31c8d79904c3730805feb3dc
Commit:        ceb79c9a500f38ac31c8d79904c3730805feb3dc
Parent:        2276379a71ec9d790241633b013a707a07c5046b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 13 14:41:57 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 14:49:15 2012 +0200

example.conf.in: The command to refresh lvmetad is pvscan --cache.

---
 doc/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 8cec63c..7b26bdc 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -479,7 +479,7 @@ global {
     # scanning is done by the individual commands. In a setup with lvmetad,
     # lvmetad udev rules *must* be set up for LVM to work correctly. Without
     # proper udev rules, all changes in block device configuration will be
-    # *ignored* until a manual 'vgscan' is performed.
+    # *ignored* until a manual 'pvscan --cache' is performed.
     use_lvmetad = 0
 
     # Full path of the utility called to check that a thin metadata device


