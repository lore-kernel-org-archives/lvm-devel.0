From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Jun 2015 21:49:21 +0000 (UTC)
Subject: master - doc: mention new invalid states in lvmetad_design
Message-ID: <20150623214921.CEF8160246@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba2b701f2cc98eb8e4049866f3d1cc77b61b4abd
Commit:        ba2b701f2cc98eb8e4049866f3d1cc77b61b4abd
Parent:        c23e7ff2a02c65619d05eb525adaaf9336de2692
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 23 16:48:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 23 16:48:28 2015 -0500

doc: mention new invalid states in lvmetad_design

---
 doc/lvmetad_design.txt |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/doc/lvmetad_design.txt b/doc/lvmetad_design.txt
index 3b336ec..1961cfb 100644
--- a/doc/lvmetad_design.txt
+++ b/doc/lvmetad_design.txt
@@ -137,6 +137,17 @@ hosts. Overall, this is not hard, but the devil is in the details. I would
 possibly disable lvmetad for clustered volume groups in the first phase and
 only proceed when the local mode is robust and well tested.
 
+With lvmlockd, lvmetad state is kept up to date by flagging either an
+individual VG as "invalid", or the global state as "invalid".  When either
+the VG or the global state are read, this invalid flag is returned along
+with the data.  The client command can check for this invalid state and
+decide to read the information from disk rather than use the stale cached
+data.  After the latest data is read from disk, the command may choose to
+send it to lvmetad to update the cache.  lvmlockd uses version numbers
+embedded in its VG and global locks to detect when cached data becomes
+invalid, and it then tells lvmetad to set the related invalid flag.
+dct, 2015-06-23
+
 Protocol & co.
 --------------
 


