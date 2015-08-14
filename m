From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri, 14 Aug 2015 19:45:43 +0000 (UTC)
Subject: master - spec: Add cache-*.profile
Message-ID: <20150814194543.3E568606F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfb58b7e1c2d2142c0e4439d193a7ff5b07a3c67
Commit:        bfb58b7e1c2d2142c0e4439d193a7ff5b07a3c67
Parent:        8852b25fc7a676720abef99757ec073b882107a6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Aug 14 21:44:10 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Aug 14 21:45:11 2015 +0200

spec: Add cache-*.profile

---
 spec/packages.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index d781067..fc68335 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -164,6 +164,8 @@ fi
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/metadata_profile_template.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-generic.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-performance.profile
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/cache-mq.profile
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/cache-smq.profile
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive


