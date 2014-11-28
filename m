From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 28 Nov 2014 23:11:09 +0000 (UTC)
Subject: master - post-release
Message-ID: <20141128231109.AEFB7606D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9258e57a50451fbbabd72a197e6a78a2a5d898db
Commit:        9258e57a50451fbbabd72a197e6a78a2a5d898db
Parent:        e492861749195311cc71910aaacb084110a9ddbb
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 28 23:07:31 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 28 23:07:31 2014 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 851b30d..539cce1 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.114(2)-git (2014-11-28)
+2.02.115(2)-git (2014-11-28)
diff --git a/VERSION_DM b/VERSION_DM
index b4b6b50..e38dae6 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.92-git (2014-11-28)
+1.02.93-git (2014-11-28)
diff --git a/WHATS_NEW b/WHATS_NEW
index a23f766..645450c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.115 -
+=====================================
+
 Version 2.02.114 - 28th November 2014
 =====================================
   Release socket in daemon_close and protocol string in daemon_open error path.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 45d3ece..8d1f648 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.93 -
+====================================
+
 Version 1.02.92 - 24th November 2014
 ====================================
   Fix memory corruption with sorting empty string lists (1.02.86).


