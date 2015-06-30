From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Jun 2015 16:17:21 +0000 (UTC)
Subject: master - conf: Regenerate.
Message-ID: <20150630161721.40AA660E0E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92138badd48efef74ecb16213ed8a322ef33119c
Commit:        92138badd48efef74ecb16213ed8a322ef33119c
Parent:        f6ad48f0e580950a74775c8dc1058d8e6122ae69
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 30 17:09:56 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 30 17:09:56 2015 +0100

conf: Regenerate.

Fix missing --clear-needs-check-flag.
---
 conf/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 9af58db..a26066a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -855,7 +855,7 @@ global {
 	# ignorable errors and fix them later.
 	# With thin_check version 3.2 or newer you should add
 	# --clear-needs-check-flag.
-	# thin_check_options = [ "-q" ]
+	# thin_check_options = [ "-q", "--clear-needs-check-flag" ]
 
 	# Configuration option global/thin_repair_options.
 	# List of options passed to the thin_repair command.


