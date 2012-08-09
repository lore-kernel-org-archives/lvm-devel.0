From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  9 Aug 2012 14:26:47 +0000 (UTC)
Subject: master - thin: fix man page for lvs
Message-ID: <20120809142647.A64E634BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80bf4eb03546903d88affbb866c9c3750bfa08e5
Commit:        80bf4eb03546903d88affbb866c9c3750bfa08e5
Parent:        b8a6efbcc03dd21cfc765176c3e406075bfa1e02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 9 11:27:14 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 9 16:25:25 2012 +0200

thin: fix man page for lvs

Renamed discard -> discards
---
 WHATS_NEW    |    1 +
 man/lvs.8.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b0fa32f..a2a9285 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -2,6 +2,7 @@ Version 2.02.98
 =================================
   Use 'ignore' discards for thin metadata created with older versions.
   Use proper condition to check for unsupported discards settings.
+  Update lvs manpage with discards (2.02.97).
 
 Version 2.02.97 - 7th August 2012
 =================================
diff --git a/man/lvs.8.in b/man/lvs.8.in
index f492835..97e1879 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -80,7 +80,7 @@ convert_lv,
 copy_percent,
 data_lv,
 devices,
-discard,
+discards,
 lv_attr,
 lv_host,
 lv_kernel_major,


