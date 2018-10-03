From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 3 Oct 2018 14:05:56 -0400
Subject: master - spec: No %ghost for dirs at tmpfiles.d
Message-ID: <201810031805.w93I5uR0003322@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11d4e6388875f06e152a035290dc41df19dc79b6
Commit:        11d4e6388875f06e152a035290dc41df19dc79b6
Parent:        a49f494c4d9a3551fe63c702a9e8c3495fe066d0
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Oct 2 17:02:37 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 3 20:05:37 2018 +0200

spec: No %ghost for dirs at tmpfiles.d

%ghost should not be used for directories created by systemd-tmpfiles.

This may prevent package from working right after installation without
invoking systemd-tmpfiles.

See: https://pagure.io/packaging-committee/issue/439
---
 spec/packages.inc |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 67a521d..a1065a6 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -169,8 +169,8 @@ fi
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive
-%ghost %dir %{_default_locking_dir}
-%ghost %dir %{_default_run_dir}
+%dir %{_default_locking_dir}
+%dir %{_default_run_dir}
 %if %{enable_systemd}
  %{_tmpfilesdir}/%{name}.conf
  %{_unitdir}/blk-availability.service


