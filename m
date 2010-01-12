From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 12 Jan 2010 21:36:10 +0000
Subject: FW: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20100112213610.GA17760@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Log message:
	Fix allocation code not to stop at the first area of a PV that fits.
	
	This spurious 'break' has been here since this code was first committed
	in June 2005 and stopped the algorithm behaving as described in the
	comment above it and rendered the variable 'already_found_one' useless.

Please keep an eye out for any undesired side-effects of this change.

If the algorithm is looking for 10 extents, and finds the first PV has
contiguous areas of 9, 11, 13 and 15 extents, it is supposed to select the
11-extent area - the smallest one with enough space.  Actually it always
selected the largest area (15 in this case) and used that.

Previously --alloc anywhere only considered one area, the largest, from each
PV, at once.  Now it should use all the available space, as intended, *but*
still unable to split contiguous segments into two pieces automatically.  (So
if there is only one segment of 100 contiguous extents available and it needs
two segments of 50, you still need to instruct it to split it using the command
line range notation.)

Alasdair


