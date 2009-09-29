From: Petr Rockai <prockai@redhat.com>
Date: Tue, 29 Sep 2009 16:42:29 +0200
Subject: [PATCH, v2] unknown segment types
In-Reply-To: <87vdlmhze5.fsf_-_@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 21 Jul 2009 16:41:22 +0200")
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
	<4A56288F.4080604@redhat.com>
	<87k52h8wep.fsf@twilight.int.mornfall.net.>
	<4A564EEA.10607@redhat.com>
	<87vdlmhze5.fsf_-_@twilight.int.mornfall.net.>
Message-ID: <87pr99ersa.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
> here comes an amended patch for unknown segment types. This time, it won't let
> people tinker with volume groups with unknown segtypes in it, but comes with
> provisions to let tools override this safeguard when reasonable.
a rebase of this same patch for current mainline (checked that it still works,
too) is attached.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: unknown-segtype.diff
Type: text/x-diff
Size: 19394 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090929/a8dae80b/attachment.bin>
