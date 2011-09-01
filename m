From: Petr Rockai <prockai@redhat.com>
Date: Thu, 01 Sep 2011 03:08:03 +0200
Subject: [PATCH] Avoid recursive calls from dmeventd to itself
Message-ID: <8739gh3w98.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch keeps the LVM-based dmeventd plugins from trying to
manipulate the dmeventd monitoring state of the logical volumes they are
currently acting on.

Until now, every time a logical volume has been changed by a dmeventd
plugin, this plugin would have called back to dmeventd through the
external FIFO mechanism. I am fairly sure this is superfluous,
inefficient and possibly even dangerous.

It is probably related to RHBZ 707056 and I wouldn't be surprised if
this sometimes caused mirror repair issues. With the patch, the
incidence of "No longer monitoring..." messages while repairing mirrors
drops dramatically.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd_norecurse.diff
Type: text/x-diff
Size: 1806 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110901/b65fdb7c/attachment.bin>
-------------- next part --------------


-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
