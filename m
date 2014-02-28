From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:22 +0000 (UTC)
Subject: master - spec: Add a copyright header and an explanatory notice.
Message-ID: <20140228102622.A83AC60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=421ca4cd143d3d3935567a76dbed1b19d7c397ce
Commit:        421ca4cd143d3d3935567a76dbed1b19d7c397ce
Parent:        658f8976a3d755aaccbbcc161b4464da9b48f9c6
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Thu Feb 27 23:22:33 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

spec: Add a copyright header and an explanatory notice.

---
 spec/lvm2.spec |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/spec/lvm2.spec b/spec/lvm2.spec
index f339367..89b37e7 100644
--- a/spec/lvm2.spec
+++ b/spec/lvm2.spec
@@ -1,3 +1,19 @@
+# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# NB. This specfile is a work in progress. It is currently used by the
+# continuous integration system driven by nix and hydra to create and test RPMs
+# on Fedora, CentOS and RHEL systems. It is not yet ready for deployment of LVM
+# on those systems.
+
+# A macro to pull in an include file from an appropriate location.
 %define import() %include %(test -e %{S:%1} && echo %{S:%1} || echo %{_sourcedir}/%1)
 
 %import source.inc


