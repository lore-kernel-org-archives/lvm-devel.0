From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 15 Jun 2015 19:32:00 +0000 (UTC)
Subject: master - lvmcache: mention lvconvert --cachemode
Message-ID: <20150615193200.F240760D6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce18fb61c0a3b94b642edb056a717a198473449c
Commit:        ce18fb61c0a3b94b642edb056a717a198473449c
Parent:        e7eb5b069689cc0fe76a95cda2fb850a6a1d2c21
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 15 14:30:58 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 15 14:30:58 2015 -0500

lvmcache: mention lvconvert --cachemode

for changing the cache mode on an existing LV.
---
 man/lvmcache.7.in |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 493d6a9..433746b 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -254,6 +254,11 @@ defines the default cache mode.
 # lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
 .fi
 
+The cache mode can be changed on an existing LV with the command:
+
+.B lvconvert --cachemode writethrough|writeback VG/CacheLV
+
+
 .SS Cache policy & policy settings
 
 \&


