From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 14 Feb 2014 03:13:24 +0000 (UTC)
Subject: master - Update WHATS_NEW for approximate allocation check-in
Message-ID: <20140214031324.B647360FD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94d8779ae241a2742ed43acc7bb0f98b7b2da25c
Commit:        94d8779ae241a2742ed43acc7bb0f98b7b2da25c
Parent:        4b6e3b5e5ea682b4b6f7c77a447ccadc7f3c99c3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Feb 13 21:12:28 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Feb 13 21:12:28 2014 -0600

Update WHATS_NEW for approximate allocation check-in

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a089d7c..01fa616 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Allow approximate allocation when specifying size in percentage terms.
   Add basic LVM support for cache[pool] segment types.
   Use local exclusive activation for creation of raid in cluster.
   Use correctly signed 64b constant when selecting raid volumes.


