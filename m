From: Petr Rockai <prockai@redhat.com>
Date: Wed, 27 Apr 2011 14:08:49 +0200
Subject: [PATCH] Refactor lib/ code to allow deferred PV labelling
Message-ID: <87oc3rhp66.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch is a major part of a 623808 fix, making it possible to create
the PV structures in memory in an lvmlib app, and only writing the
labels upon a vg_write. Among other useful properties introduced by this
option, it should make it possible to get a pe_start out of the library
without actually creating a VG on disks, which was the original use case
for this change.

When this is in, I will follow up with the lvmlib side of the necessary
changes, which should be relatively simple in comparison.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmlib-pvcreate.diff
Type: text/x-diff
Size: 12493 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110427/aeccdc28/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
