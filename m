From: Milan Broz <mbroz@redhat.com>
Date: Mon, 04 Oct 2010 19:47:39 +0200
Subject: [PATCH] Restrict lvm1 partial mode.
In-Reply-To: <8762xh50zj.fsf@twilight.int.mornfall.net.>
References: <1286210927-10607-1-git-send-email-mbroz@redhat.com>
	<8762xh50zj.fsf@twilight.int.mornfall.net.>
Message-ID: <4CAA133B.7050502@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/04/2010 07:20 PM, Petr Rockai wrote:
> PS: Would it be possible to have automated tests for LVM1 stuff as well?
> The below seems to work (i.e. new LVM1 VGs can still be created), so we
> could just add couple tests for missing PV behaviour with LVM1...

It depends if we want to spend resources for supporting lvm1 format forever.

It is very rarely used today and I can remember only troubles with it:-)

Milan


