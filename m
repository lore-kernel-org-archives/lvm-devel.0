From: Eduardo Damato <eduardo.damato@canonical.com>
Date: Tue, 15 Jan 2013 17:20:06 +0000
Subject: lvmdump capture logs in debian/ubuntu
Message-ID: <50F58FC6.6050400@canonical.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hi All,

lvmdump is not capturing the logs on Ubuntu/debian systems, proposing
the patch below.

Cheers,
Eduardo.

$ git diff
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 641d109..2f62b95 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -201,7 +201,13 @@ myecho "Gathering process info..."
 log "$PS alx >> \"$dir/ps_info\" 2>> \"$log\""
 
 myecho "Gathering console messages..."
-log "$TAIL -n 75 /var/log/messages >> \"$dir/messages\" 2>> \"$log\""
+if [ -f /var/log/messages ]
+then
+       log "$TAIL -n 75 /var/log/messages >> \"$dir/messages\" 2>>
\"$log\""
+elif [ -f /var/log/syslog ]
+then
+       log "$TAIL -n 75 /var/log/syslog >> \"$dir/messages\" 2>> \"$log\""
+fi
 
 myecho "Gathering /etc/lvm info..."
 log "$CP -a /etc/lvm \"$dir/lvm\" 2>> \"$log\""


