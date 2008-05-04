From: Petr Rockai <prockai@redhat.com>
Date: Mon, 05 May 2008 01:15:09 +0200
Subject: [PATCH] partial metadata handling
Message-ID: <87skwx64qq.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

attached is a patch that does the following things:

- implements an _lv_postorder function (that may need a better name, too) --
  this will walk the LV dependency graph in depth-first order and in the
  postorder, call a callback function

- using _lv_postorder, it implements _lv_mark_partial, that decides whether any
  given LV needs to be marked as partial -- that is, it is incomplete, which
  generally means, that somewhere down the stack, a PV is missing

- a highlevel function _vg_consolidate_partial, that flags up all partial LVs
  with a PARTIAL_LV status flag

- fixes the error message in vg_write branch for PARTIAL_VG, telling the user
  that metadata cannot be updated for partial VG

- add a toolcontext flag handles_partial, that declares that the given tool can
  cope (and write out) partial metadata; all tools not setting this flag will
  exhibit the above error message -- and that should be the majority

- the obvious candidate for handles_partial right now is vgreduce
  --removemissing, but see the next patch for more tool changes

The intention is to have this patch (plus a few tool bits) commited soon
enough, as it needs some regression testing and it shouldn't impact current
behaviour in any major or negative way. Further bits will then add new
functionality on top of these changes, although those still need more work
before being commit-ready, I believe.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: partial-metadata-handling.diff
Type: text/x-diff
Size: 14170 bytes
Desc: lvm-partial-metadata-handling.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080505/c7128726/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
