From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 17:26:27 -0400
Subject: master - man lvm.conf: say how to get a description of settings
Message-ID: <201705032126.v43LQRXr006751@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=596fd0b106c2044c45827a9f71bc42f1917eba46
Commit:        596fd0b106c2044c45827a9f71bc42f1917eba46
Parent:        5de3870662688ca2a81a94f7f0422dea15949566
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 16:01:19 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 16:01:19 2017 -0500

man lvm.conf: say how to get a description of settings

Many will look in 'man lvm.conf' expecting to find a
description of the lvm.conf fields, which are not there.
State at the beginning how to get this (by running
lvmconfig.)
---
 man/lvm.conf.5_main |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/man/lvm.conf.5_main b/man/lvm.conf.5_main
index 7b777af..3a45f1c 100644
--- a/man/lvm.conf.5_main
+++ b/man/lvm.conf.5_main
@@ -10,6 +10,10 @@ being loaded - settings read in later override earlier
 settings.  File timestamps are checked between commands and if
 any have changed, all the files are reloaded.
 
+For a description of each lvm.conf setting, run:
+
+.B lvmconfig --typeconfig default --withcomments --withspaces
+
 The settings defined in lvm.conf can be overridden by any
 of these extended configuration methods:
 .TP


