From: Petr Rockai <prockai@redhat.com>
Date: Wed, 31 Aug 2011 20:57:23 +0200
Subject: [PATCH] Clear up the confusing "precommit(ed)" terminology
Message-ID: <87d3fl4df0.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

we have discussed the current use of "precommit" and "precommitted"
terminology as related to LVM metadata with Alasdair, and arrived at the
following conclusion:

The *state* of the metadata, what was most of the time called
"precommitted" (and sometimes "precommit") is changed to "tentative".

The *act* of writing the "precommitted" (i.e. tentative) metadata, which
has been called "precommit" is now more explicitly part of vg_write (the
*action* of precommitting only existed as part of metadata_area_ops and
was called vg_precommit). To reflect the two-phase nature of vg_write
with multiple MDAs, I have renamed vg_write in metadata_area_ops to
vg_write_phase1 and vg_precommit to vg_write_phase2. Other suggestions
have been made, for now I picked phase1/phase2 because it is the easiest
to track down and rename to any other combination of names.

The current (proposed) terminology therefore is:
- the metadata after vg_write, but before vg_commit is "tentative"
- the metadata after vg_write *and* vg_commit is "committed"

There is no user-visible state between not-yet-written and tentative
(even though vg_write is internally a 2-phase operation, this is not
exposed in the metadata layer API).

I am attaching 2 diffs, the first is the changes I did manually, the
second is these changes with

find -name \*.\[hc\] | xargs sed -i.orig -e 's,precommitted,tentative,g;s,PRECOMMIT\(TED\)\?,TENTATIVE,g;s,pre-committed,tentative,g;'

on top (you can use interdiff to see just the diff produced by sed).

Yours,
  Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: tentative_manual.diff
Type: text/x-diff
Size: 14529 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110831/bdafa34d/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: tentative_full.diff
Type: text/x-diff
Size: 37679 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110831/bdafa34d/attachment-0001.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
