From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 26 Feb 2016 21:14:28 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160226211428.BADCF60ECA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4013e21ba894d665130bb0d19b7cf31567cbf929
Commit:        4013e21ba894d665130bb0d19b7cf31567cbf929
Parent:        731a9c1354481524a5d8674f10f0ca57c503c655
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 26 21:14:12 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 26 21:14:12 2016 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 0444a0a..10d6493 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.144(2)-git (2016-02-26)
+2.02.145(2)-git (2016-02-26)
diff --git a/VERSION_DM b/VERSION_DM
index 52e68df..d930b03 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.118-git (2016-02-26)
+1.02.119-git (2016-02-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index e43dd29..77b0a40 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.145 - 
+=====================================
+
 Version 2.02.144 - 26th February 2016
 =====================================
   Only show (u)sed pv_attr char when PV is not (a)llocatable. (2.02.143)
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2edc675..174b6bd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.119 -
+=====================================
+
 Version 1.02.118 - 26th February 2016
 =====================================
   Fix string boundary check in _get_canonical_field_name().


