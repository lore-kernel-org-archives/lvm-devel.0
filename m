From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Oct 2013 14:57:03 +0000 (UTC)
Subject: master - tests: needed --type mirror
Message-ID: <20131008145703.A359A60D17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=830d233b1750d3fa885f75e488f18c91e98d61e5
Commit:        830d233b1750d3fa885f75e488f18c91e98d61e5
Parent:        2ee969e8514d7d7310990308a242b210e55a9113
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 8 16:56:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 8 16:56:09 2013 +0200

tests: needed --type mirror

Avoid testing raids here (would need kernel module)
---
 test/shell/lvcreate-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 68a15a9..7f32bbc 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -77,7 +77,7 @@ not lvcreate -l1 -n $lv4 $vg
 not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
 
 lvconvert -m0 $vg/$lv3
-lvconvert -m2 -i 1 $vg/$lv3
+lvconvert -m2 --type mirror -i 1 $vg/$lv3
 lvconvert -m1 $vg/$lv3
 
 not vgchange -l 2


