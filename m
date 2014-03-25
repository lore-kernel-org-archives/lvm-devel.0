From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 23:06:37 +0000 (UTC)
Subject: master - tests: disable test for broken kernel raid targe
Message-ID: <20140325230637.B280A61055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4adbb85c372b1030b67749f7f208132a2cc06a7f
Commit:        4adbb85c372b1030b67749f7f208132a2cc06a7f
Parent:        fb471a372dd8b5e750e8001304657eefa355ce6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 23:56:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 00:04:59 2014 +0100

tests: disable test for broken kernel raid targe

Since using raid5 - validate it's usable on the system
---
 test/shell/lvconvert-repair-raid.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 71c84c1..bc5483b 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -11,6 +11,7 @@
 
 . lib/test
 
+aux raid456_replace_works || skip
 aux target_at_least dm-raid 1 1 0 || skip
 
 aux lvmconf 'allocation/maximise_cling = 0'


