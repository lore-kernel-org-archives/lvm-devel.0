From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  3 Mar 2015 14:54:07 +0000 (UTC)
Subject: master - spec: Add lvmlocal.conf to RPMs.
Message-ID: <20150303145407.3F8D460366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=926b38c0d73d958e5774082ff17fb2a48e20d32e
Commit:        926b38c0d73d958e5774082ff17fb2a48e20d32e
Parent:        1a41e649a68b03fd6ea4769ed06e83f9d9785c45
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Mar 3 15:45:47 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Mar 3 15:47:13 2015 +0100

spec: Add lvmlocal.conf to RPMs.

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 9fb3060..6d6f92e 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -149,6 +149,7 @@ fi
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvmlocal.conf
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/command_profile_template.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/metadata_profile_template.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-generic.profile


