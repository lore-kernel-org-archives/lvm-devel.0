From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jan 2014 11:56:02 +0000 (UTC)
Subject: master - udev: clear temporary variable properly
Message-ID: <20140120115602.AE3DD6154A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf97d8d5f9449a2102f3e6c92efe4987744c96e9
Commit:        cf97d8d5f9449a2102f3e6c92efe4987744c96e9
Parent:        91b26b63b408b7d7b4f79f0754d190783874e4cc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 20 12:54:10 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 20 12:54:10 2014 +0100

udev: clear temporary variable properly

Clear temporary DM_DISABLE_OTHER_RULES_FLAG properly. This did not
cause any bug or problem as the temporary variable is overwritten next
time it's used again, but we should still clean it properly!
---
 udev/11-dm-lvm.rules.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
index 9ca0375..91cb991 100644
--- a/udev/11-dm-lvm.rules.in
+++ b/udev/11-dm-lvm.rules.in
@@ -33,7 +33,7 @@ IMPORT{program}="(DM_EXEC)/dmsetup splitname --nameprefixes --noheadings --rows
 ENV{DM_SUBSYSTEM_UDEV_FLAG0}=="1", ENV{DM_NOSCAN}="1", ENV{DM_DISABLE_OTHER_RULES_FLAG_OLD}="$env{DM_UDEV_DISABLE_OTHER_RULES_FLAG}", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
 ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", IMPORT{db}="DM_NOSCAN", IMPORT{db}="DM_DISABLE_OTHER_RULES_FLAG_OLD"
 ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="$env{DM_DISABLE_OTHER_RULES_FLAG_OLD}", \
-				   ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG_OLD}="", ENV{DM_NOSCAN}=""
+				   ENV{DM_DISABLE_OTHER_RULES_FLAG_OLD}="", ENV{DM_NOSCAN}=""
 
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 


