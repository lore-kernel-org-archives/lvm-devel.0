From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 19:02:38 +0000 (UTC)
Subject: master - tests: missing vg
Message-ID: <20150508190238.8785F60393@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d832aef09c8a96308441750b475ca96b7c91cc3
Commit:        1d832aef09c8a96308441750b475ca96b7c91cc3
Parent:        8e509b5dd50bff30e5017f572e54f4f384830a58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 8 19:17:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 21:00:10 2015 +0200

tests: missing vg

---
 test/shell/lvconvert-repair-transient.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 9bf6a9d..c9253f4 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -25,7 +25,7 @@ dmsetup status
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 aux enable_dev --silent "$dev2" "$dev4"
 
-lvs -a -o +devices | tee out
+lvs -a -o +devices $vg | tee out
 not grep unknown out
 vgreduce --removemissing $vg
 check mirror $vg 4way


