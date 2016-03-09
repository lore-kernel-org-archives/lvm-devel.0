From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 13:00:40 +0000 (UTC)
Subject: master - spec: Fix gobject dependency
Message-ID: <20160309130040.E497E608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e72184bb761a7f2c48caf5dae64e75d57f64bfe0
Commit:        e72184bb761a7f2c48caf5dae64e75d57f64bfe0
Parent:        55d1105fc9f7e81bdca0f4d489d157b79350cac8
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 9 11:42:55 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 14:00:05 2016 +0100

spec: Fix gobject dependency

Use python3-gobject-base instead of python3-gobject requiring xorg

(cherry picked from commit d929d82116759f53484e662b967165ef4fe4257c)
---
 spec/packages.inc |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 23d6fd6..817457b 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -458,7 +458,7 @@ Requires: lvm2 >= %{version}-%{release}
 Requires: dbus
 Requires: python3-dbus
 Requires: python3-pyudev
-Requires: python3-gobject
+Requires: python3-gobject-base
 Requires(post): systemd-units >= %{systemd_version}
 Requires(preun): systemd-units >= %{systemd_version}
 Requires(postun): systemd-units >= %{systemd_version}


