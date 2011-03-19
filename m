From: Petr Rockai <prockai@redhat.com>
Date: Sun, 20 Mar 2011 00:52:51 +0100
Subject: [PATCH] factor mirror_remove_missing out of lvconvert --repair
Message-ID: <87lj0aoegc.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds a new function, which ties together the code that is
responsible for removing broken parts of a mirror. This is in
preparation for refactoring vgreduce --removemissing --force, but this
patch comes with some bugfixes as well in handling some corner cases
related to temporary mirror layers. I went with lvconvert.h for now to
make the function available to other tools. We may want to move some of
the lvconvert code into lib/ eventually, but I didn't want to tangle
that into this work.

Namely, after this patch, lvconvert --repair should cope with broken
mirrors that contain temporary conversion layer. Breakage to both
immediate and non-immediate images and logs is repaired now.

I am getting a number of
  Internal error: Maps lock 13840384 < unlock 13848576

-- other than that (when I comment out the internal error) the test seem
to pass OK. Zden?k, if you could, please apply the patch and see whether
the above reproduces for you. I don't think the problem is with the new
code (but I could be wrong). Either way, review would be appreciated.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-refactor.diff
Type: text/x-diff
Size: 10831 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110320/89ca47ef/attachment.bin>
-------------- next part --------------

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
