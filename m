From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 22 Sep 2016 15:28:45 +0000 (UTC)
Subject: master - tests: fix raid repair tests to work with older target versions
Message-ID: <20160922152845.B48AE60DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5282450520c40a8d2431ab60ccc80dcaffc9c05d
Commit:        5282450520c40a8d2431ab60ccc80dcaffc9c05d
Parent:        38a6a39daa2967970da0017ac96e40af1c7fbc7b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Sep 22 17:28:20 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Sep 22 17:28:20 2016 +0200

tests: fix raid repair tests to work with older target versions

Pre 1.8 dm-raid targets status output was racy, which caused
the device status chars to be unreliable _during_ synchronization.
This shows paritcularly with tiny test devices used.

Enhance lvconvert-repair-raid.sh to not check status
chars _during_ synchronization. Just check afterwards.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aedacee..e22e606 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lvconvert-repair-raid.sh to cope with older target versions.
   Use dm_config_parse_without_dup_node_check() to speedup metadata reading.
   Fix lvconvert --repair regression
   Fix reported origin lv field for cache volumes. (2.02.133)


