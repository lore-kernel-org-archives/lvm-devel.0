From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:30 -0400
Subject: master - tests: handle su login difference
Message-ID: <201706231649.v5NGnU6i019920@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0c97b44016024676e9f1dd24a4db4a7182f9918
Commit:        d0c97b44016024676e9f1dd24a4db4a7182f9918
Parent:        cc03a872c09941f2dbd1c9d3f2d7e89070649d17
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 15:11:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:01 2017 +0200

tests: handle su login difference

Workaround case, where it matters if 'su' was user with '-' or without.
---
 test/shell/dmsetup-keyring.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/dmsetup-keyring.sh b/test/shell/dmsetup-keyring.sh
index 127d2f7..e333a6e 100644
--- a/test/shell/dmsetup-keyring.sh
+++ b/test/shell/dmsetup-keyring.sh
@@ -31,7 +31,8 @@ aux target_at_least dm-zero 1 0 0 || skip "missing dm-zero target"
 aux target_at_least dm-crypt 1 15 0 || skip "dm-crypt doesn't support keys in kernel keyring service"
 which keyctl || skip "test requires keyctl utility"
 
-keyctl newring $PREFIX-keyring @u
+keyctl new_session || true   # fails with 'su', works with 'su -'
+keyctl newring $PREFIX-keyring @s
 keyctl timeout %:$PREFIX-keyring 60
 
 trap '_teardown' EXIT


