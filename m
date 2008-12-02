From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 2 Dec 2008 02:43:13 +0000
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
In-Reply-To: <1228184768.3256.25.camel@localhost.localdomain>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<20081130042620.GF13235@agk.fab.redhat.com>
	<1228057068.3315.33.camel@localhost.localdomain>
	<20081201135915.GB26097@agk.fab.redhat.com>
	<1228184768.3256.25.camel@localhost.localdomain>
Message-ID: <20081202024313.GG26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 01, 2008 at 09:26:08PM -0500, Dave Wysochanski wrote:
> If you're not saying let the app decide, then if we split the validation
> and the create APIs, the only way I can think of ensuring the app has
> called the validation before calling the create is to somehow store a
> "passed_validation" flag somewhere (maybe within struct cmd_context).
> Seems kinda messy though since the "passed_validation" would depend on
> the create parameters.
> Maybe there is another way but I don't see it.
 
Split the validation into optional validation and compulsory validation.
Offer separate library call(s) for the optional validation, but build
the compulsory validation into the main call(s).

Alasdair
-- 
agk at redhat.com


