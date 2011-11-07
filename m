From: Petr Rockai <prockai@redhat.com>
Date: Mon, 07 Nov 2011 16:48:52 +0100
Subject: [PATCH] lvmcache and lvmetad, part 1: isolation of lvmcache
In-Reply-To: <8739eiiidu.fsf@aldalome.int.mornfall.net.> (Petr Rockai's
	message of "Mon, 24 Oct 2011 16:17:17 +0200")
References: <8739eiiidu.fsf@aldalome.int.mornfall.net.>
Message-ID: <87ipmwyluj.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Petr Rockai <prockai@redhat.com> writes:
> The plan is to, when the lvmcache is finally walled off, to create a new
> implementation (of the APIs) that only does the bare minimum to get LVM
> going and passing the testsuite. The following step would then be to
> factor this functionality out of lvmcache altogether, as far as that
> turns out to be possible. After that is done, finally, I can resume work
> on integrating lvmetad, which has been so far blocked out by lvmcache
> mis-design. In the meantime, I'll try to integrate some lvmetad tests
> into the suite (the daemon can be tested even without full LVM support).

the attached patch is a final version of the walling-off of lvmcache,
and should make the next step possible, that is, remodeling the data
representation behind the current API. The API may need to be adjusted
in the process somewhat, but hopefully not very wildly.

The version after this patch should compile and pass the testsuite
without further ado.

Yours,
   Petr

PS: In case anyone already looked at the previous version of this patch,
it should be possible to get a reasonable interdiff from this one.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmcache-1.diff
Type: text/x-diff
Size: 57217 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111107/f483305e/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
