From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 4 Mar 2011 20:42:33 +0000
Subject: [PATCH 2/2] Do not send random bytes in message
In-Reply-To: <8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>
	<8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
Message-ID: <20110304204233.GN10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 02, 2011 at 07:09:08PM +0100, Zdenek Kabelac wrote:
> struct clvm_header contains 'char args[1]' - so adding '+ 1' here
> for the message length calculation is not correct - we end up with longer
> message where last byte is uninitialized and passed to write function.
 
What are the implications beyond the immediate line of code changed?

> xid and clintid are initialized to 0.
 
What are the implications of not setting these to 0?

Alasdair


