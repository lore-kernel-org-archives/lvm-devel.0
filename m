From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Jul 2020 15:31:46 +0000 (GMT)
Subject: master - lvmdbusd: recognize lv attr letter g for integrity
Message-ID: <20200715153146.665E0386F457@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4667c4b35be03ad0dd6b0dc5aac65ac516af0a0b
Commit:        4667c4b35be03ad0dd6b0dc5aac65ac516af0a0b
Parent:        8f421bdd7ae926ab95921fb36aedc5d35fc894cc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 15 10:07:28 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 15 10:07:28 2020 -0500

lvmdbusd: recognize lv attr letter g for integrity

---
 daemons/lvmdbusd/lv.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index fd46f348b..5c4728073 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -388,7 +388,7 @@ class LvCommon(AutomatedProperties):
 					'l': 'mirror log device', 'c': 'under conversion',
 					'V': 'thin Volume', 't': 'thin pool', 'T': 'Thin pool data',
 					'e': 'raid or pool metadata or pool metadata spare',
-					'd': 'vdo pool', 'D': 'vdo pool data',
+					'd': 'vdo pool', 'D': 'vdo pool data', 'g': 'integrity',
 					'-': 'Unspecified'}
 		return self.attr_struct(0, type_map)
 


