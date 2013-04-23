From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 12:40:33 +0000 (UTC)
Subject: master - test: fix filter
Message-ID: <20130423124033.703BB35B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67fc56f5ca1e05f78cedc5f729745e176447c6b2
Commit:        67fc56f5ca1e05f78cedc5f729745e176447c6b2
Parent:        c7c5a840c1aca9712134b8afee8abcba5cb8116f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 14:28:27 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 14:28:27 2013 +0200

test: fix filter

Fix filter for use with real /dev
---
 test/shell/mdata-strings.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 16e9360..95a630e 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -14,7 +14,7 @@
 . lib/test
 
 aux prepare_devs 2
-aux lvmconf 'devices/global_filter = [ "a|.*LVMTEST.*dev/mapper/.*pv[0-9_]*$|", "r|.*|" ]'
+aux lvmconf 'devices/global_filter = [ "a|.*dev/mapper/.*LVMTEST.*pv[0-9_]*$|", "r|.*|" ]'
 
 # for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"


