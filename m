From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 30 Jul 2015 11:50:22 +0000 (UTC)
Subject: dev-bmr-dmstats-test - spec: add 'dmstats' and 'dmstats.8.in' to packages.inc
Message-ID: <20150730115022.1A09960E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ffc93139ee301919bb77df7386f7fa88ee29143
Commit:        8ffc93139ee301919bb77df7386f7fa88ee29143
Parent:        7573bd74f332fc9a57b79807c526f566b51a5ca8
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 30 12:50:00 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Jul 30 12:50:00 2015 +0100

spec: add 'dmstats' and 'dmstats.8.in' to packages.inc

---
 spec/packages.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 33dda2e..ccd8c19 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -398,7 +398,9 @@ for the kernel device-mapper.
 %defattr(-,root,root,-)
 %doc COPYING COPYING.LIB WHATS_NEW_DM VERSION_DM README INSTALL
 %attr(755,root,root) %{_sbindir}/dmsetup
+%attr(755,root,root) %{_sbindir}/dmstats
 %{_mandir}/man8/dmsetup.8.gz
+%{_mandir}/man8/dmstats.8.gz
 %if %{enable_udev}
 %doc udev/12-dm-permissions.rules
 %dir %{_udevbasedir}


