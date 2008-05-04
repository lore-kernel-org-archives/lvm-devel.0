From: Petr Rockai <prockai@redhat.com>
Date: Mon, 05 May 2008 01:14:38 +0200
Subject: preliminary [PATCH] lvconvert --repair
Message-ID: <87tzhd64rl.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch is a preliminary version of code that should add mirror
repair functionality to lvconvert. Currently, only rudimentary support for such
actions is available in the form of vgreduce --removemissing, that will
downconvert any partial mirrors as a side-effect. This is what dmeventd does
when it detects a drive failure, but such a heavyweight action is generally a
bad idea (tm).

This patch should pave a way for a less intrusive mirror repair utility, that
is fully able to operate under "partial VG" conditions (the previous patch
makes this possible at the library level). Further down the TODO is to change
dmeventd's mirror DSO to take advantage of this functionality, which in turn
makes that more useful and less dangerous.

The reasoning behind having this functionality in lvconvert is that most of
what the repair needs to do is in some way analogic to what lvconvert already
does -- although the patch is a little complex at first sight, a lot of that is
shuffling blocks of code around to make the repair more comfortable.

I would be grateful, if someone more familiar with lvconvert code could check
(and possibly explain) that FIXME I have added in front of that
list_size(&lv->segments) != 1 check. Moreover, an examination of my use of the
lp structure in the --repair branch could be handy. Although that code seems to
work as expected for me, and it should according to my understanding of the
code, I am still not 100% sure that it's right.

Thanks.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-preview.diff
Type: text/x-diff
Size: 16614 bytes
Desc: lvm-lvconvert-repair-preview.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080505/844036a9/attachment.bin>
-------------- next part --------------

Yours,
    Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
