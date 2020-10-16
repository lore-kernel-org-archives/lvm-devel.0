From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:34 +0000 (GMT)
Subject: stable-2.02 - gitignore: ignore all cscope generated files
Message-ID: <20201016191134.E95E0396EC85@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b579fa79655ca7cf61ce0d7723b42f5ac741f2b
Commit:        5b579fa79655ca7cf61ce0d7723b42f5ac741f2b
Parent:        9345b9cb26061824a455eda51f67824b28cb42c3
Author:        Zhao Heming <heming.zhao@suse.com>
AuthorDate:    Thu Sep 10 23:38:07 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

gitignore: ignore all cscope generated files

When using cscope to read code, it will generate below 3 files for speedup
cross-refer: cscope.files, cscope.in.out, cscope.po.out

The .gitignore only contains "/cscope.out". It a little bit messy when
executing 'git status', and other git commands.
This patch add all cscope generated files in .gitignore.

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 .gitignore | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/.gitignore b/.gitignore
index f51bb67fc..9fc9101d1 100644
--- a/.gitignore
+++ b/.gitignore
@@ -28,7 +28,9 @@ make.tmpl
 /config.log
 /config.status
 /configure.scan
-/cscope.out
+/cscope.*
+/html/
+/reports/
 /tags
 /tmp/
 


