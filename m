From: Petr Rockai <prockai@redhat.com>
Date: Mon, 13 Dec 2010 00:02:05 +0100
Subject: [PATCH] percent attribute API for lvm2app (BZ 654441)
Message-ID: <8762uy8uj6.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am attaching a draft patch for $SUBJ. It is mostly OK in my opinion,
with one catch: it is not clear at all how to deal with multiple public
headers. For now, I have copied over interesting bits of the private
header into the public one, but ultimately, I would like to be able to
have headers from lib/ to be part of the API, so that code can be shared
properly. It would also mean that the public API would come in more than
one header. I am not sure we have any infrastructure for that, right
now.

Anyway, with that caveat, the patch should be more or less OK. It comes
with a "unit" test (the test is still pretty high level, but we still
lack a lot of infrastructure for testing at any lower level; that means
it's not real unit tests, but it's a bit closer than our traditional
functional tests).

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: float-api.diff
Type: text/x-diff
Size: 8901 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101213/c84a941c/attachment.bin>
