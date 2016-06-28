From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:37 +0000 (UTC)
Subject: master - lvmdbusd: Remove unneeded comment
Message-ID: <20160628192437.A7E5B611B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c5a08521b687c7c7074b41d880e1e559d4ea6b8
Commit:        7c5a08521b687c7c7074b41d880e1e559d4ea6b8
Parent:        9e3ad37828a14924dd12f65e62194bef286a16f0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 12:45:55 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:45:55 2016 -0500

lvmdbusd: Remove unneeded comment

---
 daemons/lvmdbusd/lv.py |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 8f063dc..5658d29 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -472,8 +472,6 @@ class Lv(LvCommon):
 			# it is a thin lv
 			if not dbo.IsThinVolume:
 				if optional_size == 0:
-					# TODO: Should we pick a sane default or force user to
-					# make a decision?
 					space = dbo.SizeBytes / 80
 					remainder = space % 512
 					optional_size = space + 512 - remainder


