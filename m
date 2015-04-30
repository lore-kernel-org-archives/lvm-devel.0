From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 30 Apr 2015 04:35:42 +0000 (UTC)
Subject: master - man: Fix references to lvmcache(7) that mentioned section 8 by mistake.
Message-ID: <20150430043542.AEEDB60D5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6b624686478c0f162ac4f7f4af7d35d5539d151
Commit:        d6b624686478c0f162ac4f7f4af7d35d5539d151
Parent:        299a3be0d3d02e96794bb2c36217955c2b03f049
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 22 19:38:40 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Apr 30 06:35:05 2015 +0200

man: Fix references to lvmcache(7) that mentioned section 8 by mistake.

---
 man/lvconvert.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 7dd1051..576859b 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -220,11 +220,11 @@ Run the daemon in the background.
 .BR \-H ", " \-\-cache ", " \-\-type\ \fIcache
 Converts logical volume to a cached LV with the use of cache pool
 specified with \fB\-\-cachepool\fP.
-For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(8).
+For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
 .TP
 .BR \-\-cachepool " " \fICachePoolLV
 This argument is necessary when converting a logical volume to a cache LV.
-For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(8).
+For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
 .TP
 .BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.


