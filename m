From: Petr Rockai <prockai@redhat.com>
Date: Wed, 16 Feb 2011 09:37:18 +0100
Subject: [PATCH] make vg_mark_partial_lvs more robust and export it
Message-ID: <877hd0v0ht.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the following patch makes vg_mark_partial_lvs also clear existing
PARTIAL_LV flags, so it can be issued repeatedly on the same VG, keeping
the PARTIAL_LV flags up to date.

This will be useful in a vgreduce --removemissing --force refactor
later.

The patch is simple and straightforward.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg-mark-partial.diff
Type: text/x-diff
Size: 2200 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110216/6521ca64/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
