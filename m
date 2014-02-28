From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:16 +0000 (UTC)
Subject: master - NIX: On RHEL<=6 and FC<=16, udevd is /sbin/udevd.
Message-ID: <20140228102616.77A1A60F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9770c03ce0e7a955a6c6a4f7921ccdaf9c3bb1f0
Commit:        9770c03ce0e7a955a6c6a4f7921ccdaf9c3bb1f0
Parent:        2c99601267072a6d9b8e418f860b7b6726eb9561
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jan 23 22:12:00 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: On RHEL<=6 and FC<=16, udevd is /sbin/udevd.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 0973bc2..9a688dd 100644
--- a/release.nix
+++ b/release.nix
@@ -25,7 +25,7 @@ let
       cd `cat /tmp/build-location`
       mv test/results/list test/results/list-rpm
       rpm -Uvh /tmp/rpmout/RPMS/*/*.rpm # */
-      (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) &
+      (/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || /sbin/udevd || find / -xdev -name \*udevd) &
       make check_system QUIET=1 T=${T} || touch $out/nix-support/failed
       mv test/results/list test/results/list-system
       cat test/results/list-* > test/results/list


