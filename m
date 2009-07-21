From: Petr Rockai <prockai@redhat.com>
Date: Tue, 21 Jul 2009 16:41:22 +0200
Subject: [PATCH, v2] unknown segment types
In-Reply-To: <4A564EEA.10607@redhat.com> (Milan Broz's message of "Thu, 09 Jul
	2009 22:11:22 +0200")
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
	<4A56288F.4080604@redhat.com>
	<87k52h8wep.fsf@twilight.int.mornfall.net.>
	<4A564EEA.10607@redhat.com>
Message-ID: <87vdlmhze5.fsf_-_@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

here comes an amended patch for unknown segment types. This time, it won't let
people tinker with volume groups with unknown segtypes in it, but comes with
provisions to let tools override this safeguard when reasonable.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-unknown-segments-2.diff
Type: text/x-diff
Size: 19394 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090721/9bc8d801/attachment.bin>
