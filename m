From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 8 Mar 2011 13:39:20 +0000
Subject: [PATCH 2/2] Do not send random bytes in message
In-Reply-To: <8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>
	<8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
Message-ID: <20110308133920.GC10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 02, 2011 at 07:09:08PM +0100, Zdenek Kabelac wrote:
> struct clvm_header contains 'char args[1]' - so adding '+ 1' here
> for the message length calculation is not correct - we end up with longer
> message where last byte is uninitialized and passed to write function.
 
That size calcluation is unclear to me: I doubt that args[1] was the reason for
the +1.  As long as you have confirmed there are no types/combinations of
messages or architectures that need it, ack.

> xid and clintid are initialized to 0.
> 
> Memory allocation is checked for NULL - though it's not really clear what
> should happen in this case - so just log the message - probably it will 
> fail few moments later...
 
I think it's important here that malloc cannot fail:)
(Does it inherit the right lock-into-memory settings from its lvm linking or
is something missing?)

Ack.

Alasdair


