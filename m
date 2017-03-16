From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 08:05:06 -0400
Subject: master - spec: Profiles are not %config(noreplace)
Message-ID: <201703161205.v2GC566v009038@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf0bf4b3143209007c98ae9857f4d68488b5b39f
Commit:        cf0bf4b3143209007c98ae9857f4d68488b5b39f
Parent:        a4a6a7a526e1ef43a710fef8330242f95c8e5e34
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 14 14:39:44 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 13:02:24 2017 +0100

spec: Profiles are not %config(noreplace)

These files are just examples and should not be edited by user.
---
 spec/packages.inc |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index d3a9e88..cfe6736 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -174,13 +174,13 @@ fi
 %attr(644, -, -) %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
 %attr(644, -, -) %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvmlocal.conf
 %dir %{_sysconfdir}/lvm/profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/command_profile_template.profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/metadata_profile_template.profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-generic.profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-performance.profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/cache-mq.profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/cache-smq.profile
-%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/lvmdbusd.profile
+%{_sysconfdir}/lvm/profile/command_profile_template.profile
+%{_sysconfdir}/lvm/profile/metadata_profile_template.profile
+%{_sysconfdir}/lvm/profile/thin-generic.profile
+%{_sysconfdir}/lvm/profile/thin-performance.profile
+%{_sysconfdir}/lvm/profile/cache-mq.profile
+%{_sysconfdir}/lvm/profile/cache-smq.profile
+%{_sysconfdir}/lvm/profile/lvmdbusd.profile
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache
 %dir %{_sysconfdir}/lvm/archive


