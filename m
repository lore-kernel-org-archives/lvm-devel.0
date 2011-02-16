From: Petr Rockai <prockai@redhat.com>
Date: Wed, 16 Feb 2011 09:45:30 +0100
Subject: [PATCH] lvconvert --repair refactor
Message-ID: <87y65gtljp.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch (no functional change intended, apart from a minor
bug fix) adds a new entry point in the mirror lvconvert code, for
removing missing mirror images and/or logs, without attempting any
further actions.

The minor bug fix relates to the warning messages issued at the end of
_lv_convert_mirror_repair, which sometimes fired even if they weren't
supposed to (and sometimes got the counts wrong, too).

The new entry point will be useful in vgreduce --removemissing --force
for treating mirrors, replacing a lot of custom code. Unfortunately, it
turns out that the code that lvconvert uses (_remove_mirror_images in
metadata/mirror.c) has some bugs on its own that need fixing before
vgreduce can be completely switched over.

Nevertheless, I'm going to post the draft patch for vgreduce and then
try to hunt down the _remove_mirror_images bugs.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-refactor.diff
Type: text/x-diff
Size: 8482 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110216/2f9f9894/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
