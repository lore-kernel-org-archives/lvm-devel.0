From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 30 Sep 2013 09:14:00 +0000 (UTC)
Subject: master - udev: make subsystem rules responsible for importing subsystem flags
Message-ID: <20130930091400.2181A60DCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec9b3dcecc8fe153a8838419f3ad9f0f7b7d5ad3
Commit:        ec9b3dcecc8fe153a8838419f3ad9f0f7b7d5ad3
Parent:        24ffd5244feca36ef26d4c1453ee680508466475
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 30 11:11:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 30 11:11:18 2013 +0200

udev: make subsystem rules responsible for importing subsystem flags

Each subsystem rule that needs to import any of DM_SUBSYSTEM_UDEV_FLAG*
flags is responsible for doing so. This simply moves control of these
flags from general 10-dm.rules to any subsystem rule using these flags
as each subsystem knows better how to handle these flags on its own.
---
 WHATS_NEW_DM        |    1 +
 udev/10-dm.rules.in |    8 --------
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e0ad76c..8456edd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.82 - 
 =====================================
+  Make subsystem udev rules responsible for importing DM_SUBSYSTEM_UDEV_FLAG*.
 
 Version 1.02.81 - 23rd September 2013
 =====================================
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index bc9681f..f7088f1 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -54,14 +54,6 @@ IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
 IMPORT{db}="DM_UDEV_PRIMARY_SOURCE_FLAG"
 IMPORT{db}="DM_UDEV_FLAG7"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG2"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG3"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG4"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG5"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG6"
-IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"
 IMPORT{db}="DM_UDEV_RULES_VSN"
 LABEL="dm_flags_done"
 


