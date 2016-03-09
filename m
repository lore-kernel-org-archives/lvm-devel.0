From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 10:10:37 +0000 (UTC)
Subject: master - spec: Add missing dependency for dbusd
Message-ID: <20160309101037.51F6A607B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7ca164597ec5f334c061ffbad78677c4b36f281
Commit:        d7ca164597ec5f334c061ffbad78677c4b36f281
Parent:        cb968ee875a232c8ca19c6277c0fcb223cbed93b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 23 10:30:39 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 10:58:21 2016 +0100

spec: Add missing dependency for dbusd

(cherry picked from commit 7435de21492f6b37ac7664d1f27b4a8dcc4d0dd4)
---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index bfc6703..23d6fd6 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -458,6 +458,7 @@ Requires: lvm2 >= %{version}-%{release}
 Requires: dbus
 Requires: python3-dbus
 Requires: python3-pyudev
+Requires: python3-gobject
 Requires(post): systemd-units >= %{systemd_version}
 Requires(preun): systemd-units >= %{systemd_version}
 Requires(postun): systemd-units >= %{systemd_version}


