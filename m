From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 20 Apr 2009 12:45:09 +0200
Subject: [PATCH 3/4] Udev integration: add cookie support for dmsetup
In-Reply-To: <20090415185256.GM7843@agk.fab.redhat.com>
References: <49DC978E.4040101@redhat.com>
	<20090415185256.GM7843@agk.fab.redhat.com>
Message-ID: <49EC5235.8000905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/15/2009 08:52 PM, Alasdair G Kergon wrote:
> On Wed, Apr 08, 2009 at 02:24:46PM +0200, Peter Rajnoha wrote:
>> A new command is added "notify" with the cookie value as the
>> parameter. 
> 
> "Notify" is a very general term and we might want to use something similar in
> an unrelated way in future: can we think up a more-specific command name?

Ehm, I'm not good at finding new names for new commands, so if anybody has
a good idea, speak up! Thanks. :)

Peter


