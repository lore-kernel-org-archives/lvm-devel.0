From: Petr Rockai <prockai@redhat.com>
Date: Tue, 01 Dec 2009 15:18:33 +0100
Subject: [PATCH] #define and use INTERNAL_ERROR
Message-ID: <87eine4w1y.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

patch attached to #define an INTERNAL_ERROR macro and use it throughout
LVM. There's a couple of internal errors in libdm as well, and it seems
that the log_error used by libdm actually comes from lib/ (i.e. LVM) so
it may make sense to convert those as well.

Yours,
    Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: internal-err-define.diff
Type: text/x-diff
Size: 14524 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091201/ccccc6fb/attachment.bin>
