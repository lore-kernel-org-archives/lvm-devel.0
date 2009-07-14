From: Petr Rockai <prockai@redhat.com>
Date: Tue, 14 Jul 2009 15:15:30 +0200
Subject: [PATCH] vg_read: port process_each_pv, obliterate lockingfailed() ...
Message-ID: <87d483flsd.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have rebased further 4 patches from the old vg_read series. These should be
the last ones, and we went through them with Alasdair in Berlin. Basically,
just a quick glance should be fine, we have already agreed that they do the
right thing. The test-suite still passes as well.

They are mostly straight rebase, I still have to change a few names in them
(boottime locking, now if I could recall what name we agreed on in Berlin...).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: 1.diff
Type: text/x-diff
Size: 6498 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090714/43038d70/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 2.diff
Type: text/x-diff
Size: 6796 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090714/43038d70/attachment-0001.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 3.diff
Type: text/x-diff
Size: 4586 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090714/43038d70/attachment-0002.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 4.diff
Type: text/x-diff
Size: 646 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090714/43038d70/attachment-0003.bin>
