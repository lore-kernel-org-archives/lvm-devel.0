From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  7 Apr 2016 22:22:17 +0000 (UTC)
Subject: master - WHATS_NEW: update
Message-ID: <20160407222217.103B060F86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2d4f53c827a14597e51956adb2202d32660f54c
Commit:        e2d4f53c827a14597e51956adb2202d32660f54c
Parent:        7dcbf1dfd0bc5e2d057d41900f10016d170bdae2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 7 22:20:01 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 7 22:31:40 2016 +0200

WHATS_NEW: update

doc for previous commits.
---
 WHATS_NEW    |    2 ++
 WHATS_NEW_DM |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b1da1b0..0c940b6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,8 @@
 Version 2.02.150 -
 =================================
   Allow the lvmdump directory to exist already provided it is empty.
+  Show lvconverted percentage with 2 decimal digits.
+  Fix regression in suspend when repairing --type mirror (2.02.133).
 
 Version 2.02.149 - 1st April 2016
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d84f8cf..6bd857e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.122 - 
 ==================================
+  Improve log_debug ioctl bit attrs.
 
 Version 1.02.121 - 26th March 2016
 ==================================


