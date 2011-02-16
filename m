From: Petr Rockai <prockai@redhat.com>
Date: Wed, 16 Feb 2011 09:57:03 +0100
Subject: [PATCH] make vg_mark_partial_lvs more robust and export it
In-Reply-To: <877hd0v0ht.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Wed, 16 Feb 2011 09:37:18 +0100")
References: <877hd0v0ht.fsf@twilight.int.mornfall.net.>
Message-ID: <87sjvotl0g.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hey again,

Petr Rockai <prockai@redhat.com> writes:
> the following patch makes vg_mark_partial_lvs also clear existing
> PARTIAL_LV flags, so it can be issued repeatedly on the same VG, keeping
> the PARTIAL_LV flags up to date.
>
> The patch is simple and straightforward.

scratch that. It introduces a bug nevertheless. Attaching a fixed
version.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg-mark-partial.diff
Type: text/x-diff
Size: 3607 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110216/a3f0eefa/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
