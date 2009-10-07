From: Petr Rockai <prockai@redhat.com>
Date: Wed, 07 Oct 2009 22:53:06 +0200
Subject: [PATCH, v3] unknown segment types
In-Reply-To: <87pr99ersa.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 29 Sep 2009 16:42:29 +0200")
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
	<4A56288F.4080604@redhat.com>
	<87k52h8wep.fsf@twilight.int.mornfall.net.>
	<4A564EEA.10607@redhat.com>
	<87vdlmhze5.fsf_-_@twilight.int.mornfall.net.>
	<87pr99ersa.fsf@twilight.int.mornfall.net.>
Message-ID: <87k4z79b9p.fsf_-_@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

I have done some changes to the patch, namely (we have discussed those with
Alasdair on IRC):

Wed Oct  7 22:25:28 CEST 2009  Petr Rockai <me@mornfall.net>
  * Move filtering logic from export to import, cleaning up code a bit.
Wed Oct  7 22:09:05 CEST 2009  Petr Rockai <me@mornfall.net>
  * Get rid of a global variable (use batons instead).
Wed Oct  7 22:08:22 CEST 2009  Petr Rockai <me@mornfall.net>
  * Improve log_warn message (unknown -> unrecognised).

Dave, this patch should apply cleanly to CVS as of *right now*. I don't know
about the previous one.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: unknown-segtype.diff
Type: text/x-diff
Size: 20444 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091007/b98963c1/attachment.bin>
