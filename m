From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:49 +0000 (UTC)
Subject: master - tests: keep using [] for hidden volumes
Message-ID: <20160421231849.21F6360DBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69c2f560053c0a5217592d571aa9ea03a6dbc267
Commit:        69c2f560053c0a5217592d571aa9ea03a6dbc267
Parent:        8c4b717f4db7e3aed2a6e1f8bf7f5ecb722d35e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 00:04:23 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:14:56 2016 +0200

tests: keep using [] for hidden volumes

Figure out which test needs to see hidden volumes without [].
But normally use [] for debug printing in tests.
It's confusing otherwise.
---
 test/lib/aux.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3a44ae6..08187b5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1074,7 +1074,6 @@ log/level = 9
 log/overwrite = 1
 log/syslog = 0
 log/verbose = 0
-report/mark_hidden_devices=0
 EOF
 	}
 


