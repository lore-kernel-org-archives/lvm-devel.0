From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:04 +0000 (UTC)
Subject: dev-mornfall-activate - test: wait for pid removal
Message-ID: <20130604192604.3A9C36115D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4741e449e66d19a0285ee1772e0d40da2fd8d5c0
Commit:        4741e449e66d19a0285ee1772e0d40da2fd8d5c0
Parent:        f7d55118765dade557fea9e39cbe98d94aebbca3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 15:21:11 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:44:15 2013 +0200

test: wait for pid removal

---
 test/shell/clvmd-restart.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index e88e187..b288ad8 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -55,6 +55,7 @@ vgchange -an $vg
 
 # Test what happens after 'reboot'
 kill "$LOCAL_CLVMD"
+while test -e "/var/run/clvmd.pid"; do echo -n .; sleep .1; done # wait for the pid removal
 aux prepare_clvmd
 
 vgchange -ay $vg


