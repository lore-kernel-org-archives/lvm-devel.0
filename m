From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:13 +0000 (UTC)
Subject: master - NIX: Add default.profile to the spec file.
Message-ID: <20140228102513.A65FA60CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cad28a49ab48a08f781594cde0bb73b85f2694a0
Commit:        cad28a49ab48a08f781594cde0bb73b85f2694a0
Parent:        28143505f83ab0e62de326118c64a834885618fc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 23:38:02 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Add default.profile to the spec file.

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index b6f09f3..98a7848 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -141,6 +141,7 @@ fi
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/default.profile
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive


