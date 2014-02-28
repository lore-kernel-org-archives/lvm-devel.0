From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:55 +0000 (UTC)
Subject: master - NIX: Revert to calling make check inside the RPM build.
Message-ID: <20140228102555.9951360F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00dee59702009db28ce34249c7fb287d2fe0ca3f
Commit:        00dee59702009db28ce34249c7fb287d2fe0ca3f
Parent:        13d5c78a8d5f09b91e26cd49fffa05313d2f6c82
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 17:29:08 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Revert to calling make check inside the RPM build.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 0f85493..395b413 100644
--- a/release.nix
+++ b/release.nix
@@ -171,7 +171,7 @@ let
          echo "dmsetup targets\\";
          echo "dmesg --console-level debug || dmesg 8 || true\\";
          echo "(/usr/lib/systemd/systemd-udevd || /usr/lib/udev/udevd || find / -name \*udevd) & \\";
-         echo "make check_full T=${T} || touch \$out/nix-support/failed \\"
+         echo "make check T=${T} || touch \$out/nix-support/failed \\"
 	 echo "cp -R test/results /tmp/test-results \\"
          echo "make lcov && cp -R lcov_reports /tmp/lcov") >> source.inc
         sed -e "s,\(device_mapper_version\) [0-9.]*$,\1 $version_dm," \


