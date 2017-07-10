From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:27:32 -0400
Subject: master - tests: fix quoting
Message-ID: <201707101227.v6ACRWv9021665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d606891e4ae82ac1841d76d01e9425ca67ae9fa1
Commit:        d606891e4ae82ac1841d76d01e9425ca67ae9fa1
Parent:        494d819a6f5e5dbc978cf095cb2ff41b15d4f57a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:42:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: fix quoting

---
 test/shell/select-tools.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index 2b28599..e0ceccc 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -67,7 +67,7 @@ check vg_field $vg2 vg_tags 105
 vgchange --deltag 105
 
 # select contains PVS field
-vgchange --addtag 106 -S "pv_name="$dev1""
+vgchange --addtag 106 -S pv_name="$dev1"
 check vg_field $vg1 vg_tags 106
 not check vg_field $vg2 vg_tags 106
 vgchange --deltag 106


