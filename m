From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:41 +0000 (UTC)
Subject: master - tests: check default policy is used when unspecified
Message-ID: <20160505220141.E37CE60C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bb39af03630beb91acd457b9d949f7ecfa0e75e
Commit:        7bb39af03630beb91acd457b9d949f7ecfa0e75e
Parent:        95f0e25601155755baf4ea1649cd241949120185
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 21:35:19 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:55:20 2016 +0200

tests: check default policy is used when unspecified

If the policy is not given with policy settings we assume
the default one is going to be used - it's users responsibility
to pair them properly.
---
 test/shell/lvcreate-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 8f35f93..fbea5b8 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -229,7 +229,7 @@ fail lvcreate -H -L10 --chunksize 16M $vg/cpool4
 lvremove -f $vg
 
 lvcreate --type cache-pool -L10 $vg/cpool
-lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq --cachesettings migration_threshold=233
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachesettings migration_threshold=233
 dmsetup status | grep $vg
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
 lvchange -an $vg


