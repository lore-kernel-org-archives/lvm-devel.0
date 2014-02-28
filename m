From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:57 +0000 (UTC)
Subject: master - spec: Make it possible for %check_commands to prevent %clean-ing.
Message-ID: <20140228102557.B9F2B60F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d567d0d307f0e4200dc4a5138ce4079cc1560092
Commit:        d567d0d307f0e4200dc4a5138ce4079cc1560092
Parent:        00dee59702009db28ce34249c7fb287d2fe0ca3f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 21:12:06 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

spec: Make it possible for %check_commands to prevent %clean-ing.

---
 spec/build.inc |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index fd455bb..95c9b83 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -45,4 +45,5 @@ test -e %{_sourcedir}/source.inc || cp source.inc build.inc packages.inc macros.
 %{?check_commands}
 
 %clean
-rm -rf $RPM_BUILD_ROOT
+pwd
+test -n rpm-no-clean || rm -rf $RPM_BUILD_ROOT


