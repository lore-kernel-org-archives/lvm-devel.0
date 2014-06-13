From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Jun 2014 08:01:51 +0000 (UTC)
Subject: master - spec: new thin-generic.profile
Message-ID: <20140613080151.E7CB2602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c9fbe048fa9a7b9c21ef96aa431a28151acdb1d
Commit:        4c9fbe048fa9a7b9c21ef96aa431a28151acdb1d
Parent:        8e0687ca690f9c5aa009e4b1963d46a03f8ba54c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 13 10:01:34 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 13 10:01:34 2014 +0200

spec: new thin-generic.profile

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 4862430..f0b7cfd 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -150,6 +150,7 @@ fi
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/command_profile_template.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/metadata_profile_template.profile
+%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-generic.profile
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/profile/thin-performance.profile
 %dir %{_sysconfdir}/lvm/backup
 %dir %{_sysconfdir}/lvm/cache


