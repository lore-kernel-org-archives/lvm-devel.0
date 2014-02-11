From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:38 +0000 (UTC)
Subject: master - tests: remove debug.log in enable_dev
Message-ID: <20140211180138.A24C560FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ed831e7ef4cc82c84731294f0189620ff5439c5
Commit:        4ed831e7ef4cc82c84731294f0189620ff5439c5
Parent:        108ae0edc6a6c4bb771fa7931fc1e709793ddadf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 13:42:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:06 2014 +0100

tests: remove debug.log in enable_dev

In aux functions we may drop debug log from
last running lvm command - so we do not
get debug log from properly executed command,
when we fail here.
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3c02d40..9420528 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -393,6 +393,7 @@ disable_dev() {
 enable_dev() {
 	local dev
 
+	rm -f debug.log
 	init_udev_transaction
 	for dev in "$@"; do
 		local name=$(echo "$dev" | sed -e 's,.*/,,')


