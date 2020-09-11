From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:45 +0000 (GMT)
Subject: master - gitignore: ignore all cscope generated files
Message-ID: <20200911195345.0D749386F024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c38c4d9d36d765bbbe839c00b9580f6b1b8a0ef4
Commit:        c38c4d9d36d765bbbe839c00b9580f6b1b8a0ef4
Parent:        9f78acfee9e1f50ea58b532880c5e3e2f6161105
Author:        Zhao Heming <heming.zhao@suse.com>
AuthorDate:    Thu Sep 10 23:38:07 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:42:38 2020 +0200

gitignore: ignore all cscope generated files

When using cscope to read code, it will generate below 3 files for speedup
cross-refer: cscope.files, cscope.in.out, cscope.po.out

The .gitignore only contains "/cscope.out". It a little bit messy when
executing 'git status', and other git commands.
This patch add all cscope generated files in .gitignore.

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 .gitignore | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/.gitignore b/.gitignore
index 7ebb8bb3b..cfd5bee1c 100644
--- a/.gitignore
+++ b/.gitignore
@@ -30,7 +30,7 @@ make.tmpl
 /config.log
 /config.status
 /configure.scan
-/cscope.out
+/cscope.*
 /html/
 /reports/
 /tags


