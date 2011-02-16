From: Petr Rockai <prockai@redhat.com>
Date: Wed, 16 Feb 2011 10:31:32 +0100
Subject: [DRAFT] [PATCH] vgreduce --removemissing --force refactor
Message-ID: <87mxlwtjez.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

this is just a heads-up patch for vgreduce. It is *not* intended to be
merged until the tests pass, which blocks on the _remove_mirror_images
fixes mentioned earlier. As you can see, it removes quite a lot of code,
so I am eager to get this through.

A quick "sanity" check on the patch would be appreciated, though.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgreduce-removemissing-refactor.diff
Type: text/x-diff
Size: 9807 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110216/cff184b1/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
