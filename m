From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Oct 2011 16:17:17 +0200
Subject: [DRAFT PATCH] lvmcache and lvmetad
Message-ID: <8739eiiidu.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have been working on isolating lvmcache code from the rest of the
codebase. I am making progress slowly, since this is very tedious and
very error-prone. A lot of code is copied out around the code base and
cache internals are manipulated all over the place. I am attaching my
current state of the matters, which do not yet compile. When you expose
the internal structures, you can get things to compile though and pass
the tests as well. I will continue drilling down while trying to avoid
any new bugs.

The plan is to, when the lvmcache is finally walled off, to create a new
implementation (of the APIs) that only does the bare minimum to get LVM
going and passing the testsuite. The following step would then be to
factor this functionality out of lvmcache altogether, as far as that
turns out to be possible. After that is done, finally, I can resume work
on integrating lvmetad, which has been so far blocked out by lvmcache
mis-design. In the meantime, I'll try to integrate some lvmetad tests
into the suite (the daemon can be tested even without full LVM support).

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmcache.diff
Type: text/x-diff
Size: 39299 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111024/8036749b/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
