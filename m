From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Oct 2013 11:42:11 +0200
Subject: [PATCH]: Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
In-Reply-To: <1382394852.4860.4.camel@f16>
References: <1382394852.4860.4.camel@f16>
Message-ID: <52664873.1060005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22.10.2013 00:34, Jonathan Brassow napsal(a):
> agk,
>
> The patch below is designed to address bug 1009700:
> https://bugzilla.redhat.com/show_bug.cgi?id=1009700
> It is the simplest way with the most flexibility for users that I could
> think of to handle the problem outside of doing the asynchronous label
> reads.
>


I believe the patch needs to go in different direction.

See the bug  https://bugzilla.redhat.com/show_bug.cgi?id=905028

Lvm2 should be smarter in it's scanning code and
must avoid reading device it know it may block.

There are very similar problems i.e. with thin pools, so
it's not practical to put in various hacks for individual
targets.

The fix must be in the filter to skip known dm devices.

Zdenek


