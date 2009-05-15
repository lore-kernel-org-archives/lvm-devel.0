From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 15 May 2009 19:13:14 +0100
Subject: [PATCH] Add escape sequence for ':' in command's PV list
In-Reply-To: <4A0DAD1E.4090805@redhat.com>
References: <4A0AAA51.8040609@redhat.com> <1242243809.2556.19.camel@f10-node1>
	<4A0BE56B.2000508@redhat.com> <1242329131.3943.111.camel@f10-node1>
	<1242389250.2506.6.camel@f10-node1>
	<1242390460.2506.8.camel@f10-node1> <4A0DAD1E.4090805@redhat.com>
Message-ID: <20090515181314.GM25793@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 15, 2009 at 07:57:50PM +0200, Peter Rajnoha wrote:
> OK, thanks. I'll move the code to a separate function then and I'll add checks
> for pvcreate/vgcreate, too.
 
Main thing I'm bothered about here is applying a simple policy across the board.
Having different policies in different places is a recipe for confusion.

[Note that doubling the hyphens in device names does not set a precedent
as that is meant to be an internal tool matter, not exposed to the user who
uses /dev/vgname/lvname.]

How many more things need escaping?

Is the policy "any character that needs escaping will be doubled"?  

Or do we go for "any character that needs escaping will be preceded by a
backslash"?
(See config strings - does this work with config settings on cmdline too?)

Alasdair


