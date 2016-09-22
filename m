From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Sep 2016 13:48:25 +0000 (UTC)
Subject: master - tests: raid repair needs devices in-sync
Message-ID: <20160922134825.811FB6024E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38a6a39daa2967970da0017ac96e40af1c7fbc7b
Commit:        38a6a39daa2967970da0017ac96e40af1c7fbc7b
Parent:        eb6b2a11e3548f7598c726787494be2c3ea4dca1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 22 15:46:18 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 22 15:46:18 2016 +0200

tests: raid repair needs devices in-sync

Though I'm not quite sure why we push this limit on user,
current --repair logic requires user to wait outside of command.

TODO: I'm not quite sure this repair logic is 'the most wanted'.
---
 test/shell/lvconvert-cache-raid.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index ebb9f79..3807493 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -60,7 +60,10 @@ lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
 lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
 
 lvchange --syncaction repair $vg/cpool_cmeta
+aux wait_for_sync $vg cpool_cmeta
+
 lvchange --syncaction repair $vg/cpool_cdata
+aux wait_for_sync $vg cpool_cdata
 
 lvconvert --repair -y $vg/cpool_cmeta
 lvconvert --repair -y $vg/cpool_cdata


