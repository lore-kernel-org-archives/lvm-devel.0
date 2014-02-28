From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:51 +0000 (UTC)
Subject: master - spec: Add thin-performance.profile to the filelist.
Message-ID: <20140228102551.7274A60F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49ea253aafb518ce12b70637978372768737a168
Commit:        49ea253aafb518ce12b70637978372768737a168
Parent:        8a0cf9cb0a0e2825d404b3e54ff4db0d2a472541
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 17 18:20:53 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

spec: Add thin-performance.profile to the filelist.

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 98a7848..34dc130 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -142,6 +142,7 @@ fi
 %ghost %{_sysconfdir}/lvm/cache/.cache
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/default.profile
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-performance.profile
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive


