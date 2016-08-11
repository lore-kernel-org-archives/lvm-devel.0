From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 11 Aug 2016 13:25:06 +0000 (UTC)
Subject: master - spec: Add new files
Message-ID: <20160811132506.79B9460AB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e30fb19030823cd8bb181e2b494488c18c187850
Commit:        e30fb19030823cd8bb181e2b494488c18c187850
Parent:        2fed8d8515644d25c24e8f62b450d80d34911970
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 11 14:10:24 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 11 14:10:59 2016 +0200

spec: Add new files

---
 spec/packages.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 817457b..66946be 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -115,6 +115,7 @@ fi
 %{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz
+%{_mandir}/man8/lvm-fullreport.8.gz
 %{_mandir}/man8/lvmsadc.8.gz
 %{_mandir}/man8/lvmsar.8.gz
 %{_mandir}/man8/lvreduce.8.gz
@@ -179,6 +180,7 @@ fi
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-performance.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/cache-mq.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/cache-smq.profile
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/lvmdbusd.profile
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive


