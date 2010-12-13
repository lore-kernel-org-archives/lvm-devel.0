From: Petr Rockai <prockai@redhat.com>
Date: Mon, 13 Dec 2010 22:24:46 +0100
Subject: [PATCH] vg_validate support for pvmove LVs (BZ 662669)
Message-ID: <87ipyx74dd.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am attaching patch that revs up vg_validate somewhat, to catch some
malformed (internal) pvmoveN LVs. Currently, it checks that the segments
in there are either linear or mirrored with 2 legs. Unfortunately, I
haven't been able to come up with any further restrictions that wouldn't
break the existing tests on some count. It seems that vg_validate is
called on VGs where linear segments exist (although I have been unable
to capture them at vg_commit time), and they are interspersed with
mirrored segments in the same LV. I have already spent a lot of time on
this, so if someone wants to come up with a stricter check, please feel
free to do so.

Anyway, the attached patch does catch the bug triggered by kabi's test
attached to BZ 654447. For the other bug (dangling reference) I will
submit a separate BZ and a separate patch, hopefully tomorrow.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg_validate-pvmove.diff
Type: text/x-diff
Size: 1254 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101213/096bfb2b/attachment.bin>
