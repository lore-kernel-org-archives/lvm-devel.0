From: Petr Rockai <prockai@redhat.com>
Date: Sun, 20 Mar 2011 00:33:41 +0100
Subject: [PATCH] fix bugs in temporary mirror layer handling
Message-ID: <87pqpmofca.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

while working on vgreduce --removemissing --force, I have uncovered
about half a dozen bugs in handling mirror image removal with temporary
layers present in the mirror stack.

In some cases, we could end up with a mirrored LV without a MIRRORED
flag. In other cases, the code could wind up removing wrong number of
mirrors. In yet other cases, we could remove the right number of
mirrors, but fail to respect the removal preferences (i.e. keep an image
that was requested to be removed while removing an image that was
requested to be kept). Under some circumstances, remove_mirror_images
could also get stuck in an infinite loop.

I think the proposed version of remove_mirror_images should get through
all of these above cases correctly. I have tried to explain specific
problems in the comments in the code.

The patch did not break any tests from the test suite for me. It is a
prerequisite for vgreduce --removemissing --force, but it also fixes the
above bugs when triggered in plain lvconvert and in lvconvert --repair.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: temp-mirror-layer-fixes.diff
Type: text/x-diff
Size: 5315 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110320/ed89d66e/attachment.bin>
-------------- next part --------------

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
