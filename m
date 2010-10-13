From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 Oct 2010 14:13:40 +0200
Subject: [PATCH] Produce correct error in lvcreate of small snapshots (BZ 587063)
In-Reply-To: <87aamt52qs.fsf@twilight.int.mornfall.net.>
References: <87aamt52qs.fsf@twilight.int.mornfall.net.>
Message-ID: <4CB5A274.9020807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/04/2010 06:42 PM, Petr Rockai wrote:
> this should fix BZ 587063, by producing an intelligible error
> message. Automated test included (test/t-lvcreate-small-snap.sh).

seems straightforward, ack.

Milan


