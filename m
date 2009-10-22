From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 22 Oct 2009 01:01:36 +0100
Subject: [PATCH] Enable (already implemented?) snapshots of mirrors
In-Reply-To: <13B333BC-2DD2-4176-8AD9-73FE0AFC2A27@redhat.com>
References: <1255637948.16495.26.camel@hydrogen.msp.redhat.com>
	<20091021130847.GB10165@agk-dp.fab.redhat.com>
	<13B333BC-2DD2-4176-8AD9-73FE0AFC2A27@redhat.com>
Message-ID: <20091022000136.GD10165@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 21, 2009 at 05:05:42PM -0500, Jon Brassow wrote:
> On Oct 21, 2009, at 8:08 AM, Alasdair G Kergon wrote:
>> (Basically you check through all the options of all the commands
>> one-by-one and test every aspect which might behave differently
>> in respect of snapshots of mirrors

> Ok, I'll get things started.  You can tell me if I miss anything.(?)

Well when I do this, I list all the commands (alphabetically) in the
tools dir, and then run each in turn with -h to remind me of the complete
functionality of the command, and test anything I think needs testing.
(Most commands get eliminated very quickly of course, then you're normally just
left with a small number of scenarios to set up and test.)

Alasdair


