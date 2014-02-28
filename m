From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:24 +0000 (UTC)
Subject: master - NIX: Add a short README (to be expanded).
Message-ID: <20140228102624.BE08D60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b86489843ea1d82430fbf7a9d1e68d9187f6acbe
Commit:        b86489843ea1d82430fbf7a9d1e68d9187f6acbe
Parent:        421ca4cd143d3d3935567a76dbed1b19d7c397ce
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Thu Feb 27 23:36:49 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Add a short README (to be expanded).

---
 nix/README |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/nix/README b/nix/README
new file mode 100644
index 0000000..bee7a07
--- /dev/null
+++ b/nix/README
@@ -0,0 +1,13 @@
+This directory contains nix integration for building and testing LVM2 in various
+virtual machine configurations. The *.nix files are written in the nix
+declarative language (see http://nixos.org/nix).
+
+There are two basic use-cases for this integration. First, a hydra instance (see
+http://divine.fi.muni.cz/hydra/project/lvm2 and
+http://divine.fi.muni.cz/~xrockai/lvm-testmatrix.html) builds and tests LVM in
+all the configurations described in default.nix after every push to the git
+repository. Second, any nix-enabled system can very closely reproduce any of
+those test scenarios using the "build.sh" script and an appropriate checkout of
+"nixpkgs" (cf. http://nixos.org/nixpkgs).
+
+(The rest of this document is TODO.)


