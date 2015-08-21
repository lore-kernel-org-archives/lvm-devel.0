From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Aug 2015 13:38:21 +0000 (UTC)
Subject: master - WHATS_NEW
Message-ID: <20150821133821.134C16004A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81d4c4a84c92f7db8f79a17aced4fb3b86f86aa8
Commit:        81d4c4a84c92f7db8f79a17aced4fb3b86f86aa8
Parent:        1c811bfcd96abcd5058a6dc9877502072a862833
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 21 15:37:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 21 15:37:56 2015 +0200

WHATS_NEW

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3916acc..4eb852c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.129 -
 ===================================
+  Enable usage of --cachepolicy and --cachesetting with lvconvert.
+  Don't allow to reduce size of thin-pool metadata.
   Fix debug buffer overflows in cmirrord logging.
   Add --foreground and --help to cmirrord.
 


