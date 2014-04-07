From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  7 Apr 2014 18:39:09 +0000 (UTC)
Subject: master - spec: Add lvmthin.7.gz to packages.inc.
Message-ID: <20140407183909.36D6A60564@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0996b5ccf47c516b9504bc524b599ecb54800b6b
Commit:        0996b5ccf47c516b9504bc524b599ecb54800b6b
Parent:        f13977e8fe346c0d50fe7f8810ec66c7518c9041
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Apr 7 12:01:01 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Apr 7 20:38:42 2014 +0200

spec: Add lvmthin.7.gz to packages.inc.

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 0e54bcb..16b90e0 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -83,6 +83,7 @@ fi
  %{_sbindir}/lvmetad
 %endif
 %{_mandir}/man5/lvm.conf.5.gz
+%{_mandir}/man7/lvmthin.7.gz
 %{_mandir}/man8/fsadm.8.gz
 %{_mandir}/man8/lvchange.8.gz
 %{_mandir}/man8/lvconvert.8.gz


