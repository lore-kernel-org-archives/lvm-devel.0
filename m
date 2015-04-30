From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 16:01:06 +0000 (UTC)
Subject: master - man: lvmconfig: also mention '--type list' in synopsis
Message-ID: <20150430160106.EA28F60067@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f25606d3acd9f5e314b40384ef2366ef63bf4b1
Commit:        8f25606d3acd9f5e314b40384ef2366ef63bf4b1
Parent:        fc65269d682cb7bcaf14c94ec4541e7af4c27165
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 18:00:39 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 18:00:39 2015 +0200

man: lvmconfig: also mention '--type list' in synopsis

---
 man/lvmconfig.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 1f70c86..4e61280 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -6,7 +6,7 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-f | \-\-file
 .IR filename ]
 .RB [ \-\-type
-.RI { current | default | diff | missing | new | profilable | profilable-command | profilable-metadata }
+.RI { current | default | diff | list | missing | new | profilable | profilable-command | profilable-metadata }
 .RB [ \-\-atversion
 .IR version ]
 .RB [ \-\-ignoreadvanced ]


