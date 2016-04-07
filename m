From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  7 Apr 2016 22:22:25 +0000 (UTC)
Subject: master - tests: require newer cache target
Message-ID: <20160407222225.5B30F60E06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=248f47d489df42ce29f74f71185a4e266a9e78e0
Commit:        248f47d489df42ce29f74f71185a4e266a9e78e0
Parent:        9ab53dddf553867ba9a19367bf74307a36c43c9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 8 00:04:26 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 8 00:04:26 2016 +0200

tests: require newer cache target

Older cache target is likely not updating status at all...
---
 test/shell/lvconvert-repair-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 1fdfd3f..756fd12 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -25,7 +25,7 @@ which "$FSCK" || skip
 #
 # Main
 #
-aux have_cache 1 3 0 || skip
+aux have_cache 1 5 0 || skip
 
 aux prepare_vg 4
 


