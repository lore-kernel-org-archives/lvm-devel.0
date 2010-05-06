From: Petr Rockai <prockai@redhat.com>
Date: Thu, 06 May 2010 20:53:13 +0200
Subject: [PATCH] In dmeventd, bridge LVM error log output to syslog.
Message-ID: <87mxwcq2ue.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

as discussed, this is the first part of dmeventd logging. I am not
touching any options related to debugging, that will come as a separate
patch later. This patch provides the necessary minimum for any useful
diagnostics of dmeventd/lvconvert --repair issues.

(I have tested this and it works for me.)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-logging.diff
Type: text/x-diff
Size: 2088 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100506/99cc683f/attachment.bin>
