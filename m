From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Jan 2020 11:11:12 -0500
Subject: stable-2.02 - tests: skip test when dm-delay is not available
Message-ID: <18969.120012111110700247@us-mta-170.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62888e9c7692443066e90494764791753277f02e
Commit:        62888e9c7692443066e90494764791753277f02e
Parent:        5ab4d44a3b05cf77836b3be2c812a738131367ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 21 16:49:53 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 21 16:49:53 2020 +0100

tests: skip test when dm-delay is not available

---
 test/shell/pv-corruption.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/pv-corruption.sh b/test/shell/pv-corruption.sh
index 3958ee1..b3c5059 100644
--- a/test/shell/pv-corruption.sh
+++ b/test/shell/pv-corruption.sh
@@ -17,6 +17,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# skip test early if there is no 'delay' target available
+aux target_at_least dm-delay 1 1 0 || skip "missing dm-delay target"
+touch HAVE_DM_DELAY
+
 #
 # Main
 #



