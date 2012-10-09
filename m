From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 08:51:22 +0000 (UTC)
Subject: master - example.conf: Warn about running lvmetad with use_lvmetad = 0.
Message-ID: <20121009085122.6F4C6A0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d414fe28fa1754690e8c72a16df5c2cdc1cc87e1
Commit:        d414fe28fa1754690e8c72a16df5c2cdc1cc87e1
Parent:        f0d34f383df7a00902e8d0512a815fd764ee05a9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 9 10:47:29 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 10:49:26 2012 +0200

example.conf: Warn about running lvmetad with use_lvmetad = 0.

---
 doc/example.conf.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index b4cda6f..f7344bb 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -488,6 +488,9 @@ global {
     # lvmetad udev rules *must* be set up for LVM to work correctly. Without
     # proper udev rules, all changes in block device configuration will be
     # *ignored* until a manual 'pvscan --cache' is performed.
+    #
+    # If lvmetad has been running while use_lvmetad was 0, it MUST be stopped
+    # before changing use_lvmetad to 1 and started again afterwards.
     use_lvmetad = 0
 
     # Full path of the utility called to check that a thin metadata device


