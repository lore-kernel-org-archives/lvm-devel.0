From: Mike Snitzer <snitzer@gmail.com>
Date: Tue, 23 Oct 2007 11:32:56 -0400
Subject: [PATCH] lvm2 support for detecting v1.x MD superblocks
Message-ID: <170fa0d20710230832v3313d38fmc646d89c1b990252@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2's MD v1.0 superblock detection doesn't work at all (because it
doesn't use v1 sb offsets).

I've tested the attached patch to work on MDs with v0.90.0, v1.0,
v1.1, and v1.2 superblocks.

please advise, thanks.
Mike
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2_md_v1_sb_fix.patch
Type: text/x-patch
Size: 2059 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071023/a40b0263/attachment.bin>
