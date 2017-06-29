From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:34 -0400
Subject: master - lvmdump: replace individual redirects
Message-ID: <201706292026.v5TKQYRh025914@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=030912ec03f4ad1874351dbfb2048fa73477d914
Commit:        030912ec03f4ad1874351dbfb2048fa73477d914
Parent:        df57845f6141ac4b00e272229f65edd35912534c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 16:21:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmdump: replace individual redirects

Consider using { cmd1; cmd2; } >> file instead of individual redirects.
---
 scripts/lvmdump.sh.in |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 7ca7d0b..4bef7df 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -198,14 +198,16 @@ if (( clustered )); then
 fi
 
 myecho "Gathering LVM & device-mapper version info..."
-echo "LVM VERSION:" >> "$dir/versions"
-"$LVM" lvs --version >> "$dir/versions" 2>> "$log"
-echo "DEVICE MAPPER VERSION:" >> "$dir/versions"
-"$DMSETUP" --version >> "$dir/versions" 2>> "$log"
-echo "KERNEL VERSION:" >> "$dir/versions"
-"$UNAME" -a >> "$dir/versions" 2>> "$log"
-echo "DM TARGETS VERSIONS:" >> "$dir/versions"
-"$DMSETUP" targets >> "$dir/versions" 2>> "$log"
+{
+	echo "LVM VERSION:"
+	"$LVM" lvs --version
+	echo "DEVICE MAPPER VERSION:"
+	"$DMSETUP" --version
+	echo "KERNEL VERSION:"
+	"$UNAME" -a
+	echo "DM TARGETS VERSIONS:"
+	"$DMSETUP" targets
+} >> "$dir/versions" 2>> "$log"
 
 myecho "Gathering dmsetup info..."
 log "\"$DMSETUP\" info -c >> \"$dir/dmsetup_info\" 2>> \"$log\""


