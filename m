From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:00:29 +0000 (UTC)
Subject: master - rpm: build with raid man page
Message-ID: <20160909190029.F0582606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca7921f54b7e58ead6fecee03e6ce8504a0442b5
Commit:        ca7921f54b7e58ead6fecee03e6ce8504a0442b5
Parent:        75a42845c196e0717ac77209fc063718d0d36744
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 17:11:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 20:59:22 2016 +0200

rpm: build with raid man page

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 66946be..b74b3bd 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -99,6 +99,7 @@ fi
 %endif
 %{_mandir}/man5/lvm.conf.5.gz
 %{_mandir}/man7/lvmsystemid.7.gz
+%{_mandir}/man7/lvmraid.7.gz
 %{_mandir}/man8/blkdeactivate.8.gz
 %{_mandir}/man8/fsadm.8.gz
 %{_mandir}/man8/lvchange.8.gz


