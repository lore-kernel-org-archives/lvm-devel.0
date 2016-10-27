From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 27 Oct 2016 14:39:05 +0000 (UTC)
Subject: master - lvconvert-raid-takeover.sh: fix test
Message-ID: <20161027143905.7235661461@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61ae07966dfa68e7a03c054b1486136028c5c4a6
Commit:        61ae07966dfa68e7a03c054b1486136028c5c4a6
Parent:        ff05ed7afd16048b64ee3bd94476b1d19e5022db
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 27 16:38:15 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 27 16:38:15 2016 +0200

lvconvert-raid-takeover.sh: fix test

---
 test/shell/lvconvert-raid-takeover.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 332786d..c1cb1aa 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -16,7 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 9 0 || skip
 
-[ `aux have_raid 1.9.1` ] && correct_raid4_layout=1
+correct_raid4_layout=0
+aux have_raid 1 9 1 && correct_raid4_layout=1
 
 aux prepare_vg 9 288
 


