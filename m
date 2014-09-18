From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Sep 2014 16:19:34 +0000 (UTC)
Subject: master - WHATS_NEW
Message-ID: <20140918161934.106D46031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ffc8615e54c804180137b02106c5bff2671061c
Commit:        9ffc8615e54c804180137b02106c5bff2671061c
Parent:        b72e9d3a933fd72eb4c08f13f5a3d3a7259a7741
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 18 18:19:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 18 18:19:16 2014 +0200

WHATS_NEW

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bceed61..e06fcc2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Use -fPIE when linking -pie executables.
   Enable cache segment type by default.
   Ensure only supported volume types are used with cache segments.
   Fix inablility to specify cachemode when 'lvconvert'ing to cache-pool.


