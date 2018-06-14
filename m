From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Jun 2018 14:35:45 -0400
Subject: 2018-06-01-stable - man: update lvmsystemid wording
Message-ID: <201806141835.w5EIZjNU025951@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43ce357ebc130166866169df10f70b203f05bbe7
Commit:        43ce357ebc130166866169df10f70b203f05bbe7
Parent:        d136790bab14040412c4e02b9395d12577966ae5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 14 12:34:00 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 14 13:34:35 2018 -0500

man: update lvmsystemid wording

to refer to "shared VG" instead of "lockd VG".
---
 man/lvmsystemid.7_main |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 9b36dc3..97c67c2 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -346,9 +346,9 @@ of the foreign VG to its own.  See Overriding system ID above.
 
 .SS shared VGs
 
-A shared/lockd VG has no system ID set, allowing multiple hosts to use it
-via lvmlockd.  Changing a VG to a lockd type will clear the existing
-system ID.  Applicable only if LVM is compiled with lockd support.
+A shared VG has no system ID set, allowing multiple hosts to use it
+via lvmlockd.  Changing a VG to shared will clear the existing
+system ID.  Applicable only if LVM is compiled with lvmlockd support.
 
 
 .SS clustered VGs


