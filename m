From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:48 +0000 (UTC)
Subject: master - NIX: Set ulimit -c to unlimited, to get backtraces in logs.
Message-ID: <20150205134348.F109860FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c9d690f9e5a5490d7288441a813180eff2e20a2
Commit:        7c9d690f9e5a5490d7288441a813180eff2e20a2
Parent:        6ba05212f75b2e519c10b5758f3526cb8ca8f947
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 11:32:23 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:07 2015 +0100

NIX: Set ulimit -c to unlimited, to get backtraces in logs.

---
 nix/default.nix |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 4d7c38a..4193354 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -50,6 +50,7 @@ let
          dmsetup targets
 
          export LVM_TEST_BACKING_DEVICE=/dev/sdb
+         ulimit -c unlimited
 
          watch=
          if echo ${flavour} | grep -q udev; then


