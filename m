From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  6 Jun 2012 12:28:46 +0000 (UTC)
Subject: LVM2: master - Upstream source repo move to fedorahosted.org git.
Message-ID: <20120606122846.B8F102499@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2-commits at lists.fedorahosted.org
X-Project: Upstream Logical Volume Manager repository
X-Git-Module: LVM2.git
X-Git-Refname: refs/heads/master
X-Git-Reftype: branch
X-Git-Oldrev: 06738cac051b671ed26bd137676713eab457b37f
X-Git-Newrev: 64a3ac8f51789ae58e0b5f7b5b7bb0b036bcfd30

Gitweb:        http://git.fedorahosted.org/git/?p=LVM2.git;a=commitdiff;h=64a3ac8f51789ae58e0b5f7b5b7bb0b036bcfd30
Commit:        64a3ac8f51789ae58e0b5f7b5b7bb0b036bcfd30
Parent:        06738cac051b671ed26bd137676713eab457b37f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 6 13:26:46 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 6 13:26:46 2012 +0100

Upstream source repo move to fedorahosted.org git.

Change version number suffix from -cvs to -git.
---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    1 +
 WHATS_NEW_DM |    1 +
 4 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 3f03d98..9b83ba4 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.96(2)-cvs (2012-03-06)
+2.02.96(2)-git (2012-06-06)
diff --git a/VERSION_DM b/VERSION_DM
index 715dfc1..0711704 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.75-cvs (2012-03-06)
+1.02.75-git (2012-06-06)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2e9f710..b3f742d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Upstream source repo now fedorahosted.org git not sources.redhat.com CVS.
   Fix error paths for regex filter initialization.
   Re-enable partial activation of non-thin LVs until it can be fixed. (2.02.90)
   Fix alloc cling to cling to PVs already found with contiguous policy.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e4fc290..b5d110e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Upstream source repo now fedorahosted.org git not sources.redhat.com CVS.
   Remove unsupported udev_get_dev_path libudev call used for checking udev dir.
   Set delay_resume_if_new on deptree snapshot origin.
   Log value chosen in _find_config_bool like other variable types do.


