From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 2 Dec 2008 02:48:27 +0000
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
In-Reply-To: <20081202024313.GG26097@agk.fab.redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<20081130042620.GF13235@agk.fab.redhat.com>
	<1228057068.3315.33.camel@localhost.localdomain>
	<20081201135915.GB26097@agk.fab.redhat.com>
	<1228184768.3256.25.camel@localhost.localdomain>
	<20081202024313.GG26097@agk.fab.redhat.com>
Message-ID: <20081202024827.GH26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 02, 2008 at 02:43:13AM +0000, Alasdair G Kergon wrote:
> Split the validation into optional validation and compulsory validation.
> Offer separate library call(s) for the optional validation, but build
> the compulsory validation into the main call(s).
 
So looking at pvcreate, most of pvcreate_check() is optional and depending
on error handling could be done as one piece or broken into multiple functions.
The few bits of compulsory validation move out of there into the actual 
pvcreate call (which is performed via a vgextend() interface now).

Alasdair
-- 
agk at redhat.com


