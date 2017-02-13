From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:32 +0000 (UTC)
Subject: master - help: accept positional args
Message-ID: <20170213181032.E0B5C6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23a1ced4397b699ae572570ec772683d7003de6f
Commit:        23a1ced4397b699ae572570ec772683d7003de6f
Parent:        3642deb4f3b7ade1109aeb0ef2cffb38f31ff7c6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 13 11:31:49 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

help: accept positional args

lvm help <commandname> ...
---
 tools/command-lines.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index f99cb8c..81c70ba 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1589,6 +1589,7 @@ formats
 ID: formats_general
 
 help
+OP: String ...
 ID: help_general
 
 version


