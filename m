From: Petr Rockai <prockai@redhat.com>
Date: Sun, 27 Nov 2011 22:14:08 +0100
Subject: [PATCH] Propagate DMEVENTD_MONITOR_IGNORE to clvmd
Message-ID: <87ehwtjmjj.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

when I removed recursive calls from dmeventd to itself, I have relied on
DMEVENTD_MONITOR_IGNORE to block LVM commands from talking to
dmeventd. However, the implementation of DMEVENTD_MONITOR_IGNORE is
incorrect whenever clvmd is involved: clvmd will force monitoring off on
all volumes whenever DMEVENTD_MONITOR_IGNORE is used with current code.

This patch makes it possible to keep clvmd from touching dmeventd,
fixing the implementation of DMEVENTD_MONITOR_IGNORE and therefore also
dmeventd behaviour with locking_type 3.

The new locking flag should have no effect on older instances of clvmd
(in other words, these will still shut down monitoring whenever
--ignoremonitoring, or its equivalent used by dmeventd, is used). Old
LVM talking to new clvmd will behave as if --ignoremonitoring was always
in effect (which is probably still better than disabling monitoring on
unsuspecting users).

Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: clvmd-ignore-dmeventd.diff
Type: text/x-diff
Size: 2975 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111127/49c1fa35/attachment.bin>
-------------- next part --------------


-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
