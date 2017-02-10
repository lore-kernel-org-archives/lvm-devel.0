From: okozina <okozina@fedoraproject.org>
Date: Fri, 10 Feb 2017 13:38:30 +0000 (UTC)
Subject: dev-okozina - fix
Message-ID: <20170210133830.5ABF260DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3c00ad1911fa7e8b8d0608985b0dfde567f2dff
Commit:        b3c00ad1911fa7e8b8d0608985b0dfde567f2dff
Parent:        90088e4bf4bd084cc355f3cea052851bf40bc423
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Feb 10 14:37:02 2017 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri Feb 10 14:37:02 2017 +0100

fix

---
 test/shell/dmsetup-keyring.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
index b85b576..5ea654e 100644
--- a/test/shell/dmsetup-keyring.sh
+++ b/test/shell/dmsetup-keyring.sh
@@ -27,8 +27,8 @@ function _teardown() {
 	aux teardown_devs_prefixed $PREFIX
 }
 
-aux target_at_least zero 1 0 0 || skip "missing dm-zero target"
-aux target_at_least crypt 1 15 0 || skip "dm-crypt doesn't support keys in kernel keyring service"
+aux target_at_least dm-zero 1 0 0 || skip "missing dm-zero target"
+aux target_at_least dm-crypt 1 15 0 || skip "dm-crypt doesn't support keys in kernel keyring service"
 which keyctl || skip "test requires keyctl utility"
 
 keyctl newring $PREFIX-keyring @u


