From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Oct 2019 07:41:36 -0400
Subject: master - tests: more suffixes
Message-ID: <201910221141.x9MBfan9025775@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65efacd0e077f61842cf3bf9ff1fc42230e08947
Commit:        65efacd0e077f61842cf3bf9ff1fc42230e08947
Parent:        a7563dc6a1f8b46e13c6cf1a7fbeeb611310b29a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 22 13:31:23 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 22 13:39:39 2019 +0200

tests: more suffixes

---
 test/shell/lvcreate-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index ca8694e..b1cd515 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -221,7 +221,7 @@ lvremove -f $vg
 for i in pvmove snapshot ; do
 	invalid lvcreate -l1 -n ${i}1 $vg
 done
-for i in _cdata _cmeta _mimage _mlog _pmspare _tdata _tmeta _vorigin ; do
+for i in _cdata _cmeta _cpool _cvol _mimage _mlog _pmspare _tdata _tmeta _vorigin ; do
 	invalid lvcreate -l1 -n s_${i}_1 $vg
 done
 


